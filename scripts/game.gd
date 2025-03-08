extends Node2D

var maps: Array[Node]
var current_map: int = 0
var active_map: Node2D
@onready var maps_count: int = $Maps.get_child_count()
@onready var player: Player = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var point_light_2d: PointLight2D = $Player/PointLight2D
@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var rock_count_margin: MarginContainer = $HUD/RockCountMargin
@onready var rock_count_display: Label = $HUD/RockCountMargin/HBoxContainer/RockCountDisplay
@onready var light_bulb: TextureButton = $HUD/LightBulbMargin/LightBulb
@onready var room_count_display: Label = $HUD/RoomCountMargin/RoomCountDisplay
@onready var explosion_player: AudioStreamPlayer = $ExplosionPlayer
@onready var music_player: AudioStreamPlayer = $MusicPlayer

var fade_scene: PackedScene = load("res://scenes/fade.tscn")
var dialog_scene: PackedScene = load("res://scenes/dialog.tscn")
var pause_scene: PackedScene = load("res://scenes/pause.tscn")
var explosion_scene: PackedScene = load("res://scenes/explosion.tscn")
var stone_item_scene: PackedScene = load("res://scenes/stone_item.tscn")
var explosion_ring_scene: PackedScene = load("res://scenes/explosion_ring.tscn")

var energy_count: int = 0
var rock_count: int = 0

func _ready() -> void:
	Global.game_paused = false
	var fade_instance: Fade = fade_scene.instantiate()
	fade_instance.immediately_full_alpha = true
	fade_instance.duration = 0.5
	fade_instance.skip_to_second_half = true
	add_child(fade_instance)

	maps = $Maps.get_children()
	remove_child($Maps)
	_setup_map(current_map)

func _process(_delta: float) -> void:
	var exit_layer: TileMapLayer = active_map.find_child("Exit", true, false)
	if exit_layer:
		var tile_pos: Vector2i = exit_layer.local_to_map(player.bottom.global_position)
		var data: TileData = exit_layer.get_cell_tile_data(tile_pos)
		if data:
			if data.get_custom_data("exit") and not Global.game_paused:
				var fade_instance: Fade = fade_scene.instantiate()
				fade_instance.duration = 0.5
				fade_instance.register_callback_half(_setup_next_map)
				add_child(fade_instance)
				Global.game_paused = true

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("esc") and not Global.game_paused:
		var pause_instance: CanvasLayer = pause_scene.instantiate()
		add_child(pause_instance)

func _setup_next_map() -> void:
	Global.game_paused = false
	current_map += 1
	if current_map >= maps_count:
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
	else:
		_setup_map(current_map)

func _setup_map(num: int) -> void:
	room_count_display.text = str(num) + "/" + str(maps_count - 2)
	_clear_map()
	active_map = maps[num].duplicate()
	add_child(active_map)
	get_tree().call_group("map", "set_player", player)
	get_tree().call_group("map", "set_camera", camera)
	get_tree().call_group("map", "set_stone_count", rock_count)
	get_tree().call_group("map", "set_stone_display", rock_count_display)
	active_map.visible = true
	var down_left: Marker2D = active_map.find_child("DownLeft", true, false)
	var up_right: Marker2D = active_map.find_child("UpRight", true, false)
	var spawn: Marker2D = active_map.find_child("Spawn", true, false)
	player.global_position = spawn.global_position - player.bottom.position
	camera.limit_left = int(down_left.global_position.x)
	camera.limit_bottom = int(down_left.global_position.y)
	camera.limit_right = int(up_right.global_position.x)
	camera.limit_top = int(up_right.global_position.y)
	camera.position = Vector2.ZERO
	for child: Node in active_map.get_children():
		if is_instance_of(child, EnergyPot):
			var energy_pot: EnergyPot = child
			energy_pot.register_callback(energy_collected)

	# Map specifics
	if current_map == 9:
		canvas_modulate.visible = true
		canvas_modulate.color = Color.BLACK
		point_light_2d.enabled = true
	else:
		canvas_modulate.visible = false
		point_light_2d.enabled = false
	if current_map == 3:
		await get_tree().create_timer(2.0).timeout
		var dialog: Dialog = dialog_scene.instantiate()
		add_child(dialog)
		dialog.typing.type("This is quite a hard level, isn't it?")
		await dialog.closed
		light_bulb.visible = true
		dialog = dialog_scene.instantiate()
		add_child(dialog)
		dialog.typing.type("Luckily you can view the solution in the top right corner!")
		await dialog.closed
		dialog = dialog_scene.instantiate()
		add_child(dialog)
		dialog.typing.type("But if you don't try to solve it yourself first, a penguin will be really sad.")
	if active_map.find_child("Solution", true, false):
		light_bulb.disabled = false
	else:
		light_bulb.disabled = true
	light_bulb.set_pressed(false)
	light_bulb.visible = current_map >= 3
	if current_map == maps_count - 1:  # Ending
		room_count_display.visible = false
	else:
		room_count_display.visible = true

func _clear_map() -> void:
	if active_map:
		active_map.queue_free()

func energy_collected() -> void:
	energy_count += 1
	if energy_count == 1:
		await _show_first_energy_info()
	Global.game_paused = true
	await get_tree().create_timer(0.8).timeout
	var explosion_ring: Sprite2D = explosion_ring_scene.instantiate()
	add_child(explosion_ring)
	explosion_ring.position = player.position
	explosion_player.play()
	await get_tree().create_timer(0.3).timeout
	if canvas_modulate.visible:
		var tween_canvas: Tween = create_tween()
		tween_canvas.set_ease(Tween.EASE_IN_OUT)
		tween_canvas.tween_property(canvas_modulate, "color", Color.WHITE, 1.0)
		point_light_2d.visible = false
	var rocks: TileMapLayer = active_map.find_child("Rocks", true, false)
	if rocks:
		for used_tile: Vector2i in rocks.get_used_cells():
			rocks.set_cell(used_tile)
			var explosion: AnimatedSprite2D = explosion_scene.instantiate()
			add_child(explosion)
			explosion.position = rocks.map_to_local(used_tile)
			var stone: StoneItem = stone_item_scene.instantiate()
			add_child(stone)
			stone.position = rocks.map_to_local(used_tile)
			stone.set_target(player.bottom.global_position, 1.0)
	var post_explosion: TileMapLayer = active_map.find_child("PostExplosion", true, false)
	if post_explosion:
		post_explosion.show()
	await get_tree().create_timer(3.0).timeout
	Global.game_paused = false

func collect_rock() -> void:
	if Global.ending_active:
		return
	rock_count += 1
	rock_count_display.text = str(rock_count)

func _show_first_energy_info() -> void:
	var dialog: Dialog = dialog_scene.instantiate()
	add_child(dialog)
	dialog.typing.type(
		"You found an Energy Potion!\nCollect those to destroy the rocks in your room. " +
		"You will need them for the barrier.")
	await dialog.closed
	rock_count_margin.visible = true

func _on_light_bulb_pressed() -> void:
	var solution: Node2D = active_map.find_child("Solution", true, false)
	if solution:
		solution.visible = light_bulb.button_pressed
	light_bulb.focus_mode = Control.FOCUS_NONE

func stop_music() -> void:
	music_player.stop()
