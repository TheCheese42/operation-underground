extends Node2D

var _question_asked: bool = false
var _question2_asked: bool = false
var _player: Player
var _camera: Camera2D
var _stone_count: int
var _stone_display: Label

@onready var question_ui: CanvasLayer = $QuestionUI
@onready var yes: Label = $QuestionUI/MarginContainer/HBoxContainer/Yes
@onready var no: Label = $QuestionUI/MarginContainer/HBoxContainer/No
@onready var h_box_container: HBoxContainer = $QuestionUI/MarginContainer/HBoxContainer
@onready var barrier: Marker2D = $Barrier
@onready var explosion_player: AudioStreamPlayer = $ExplosionPlayer
@onready var barrier_player: AudioStreamPlayer = $BarrierPlayer
@onready var barrier_before: TileMapLayer = $BarrierBefore
@onready var barrier_after: TileMapLayer = $BarrierAfter
@onready var barrier_destroyed: TileMapLayer = $BarrierDestroyed

var _dialog_scene: PackedScene = load("res://scenes/dialog.tscn")
var _stone_scene: PackedScene = load("res://scenes/stone_item.tscn")
var _fade_scene: PackedScene = load("res://scenes/fade.tscn")
var _explosion_ring_scene: PackedScene = load("res://scenes/explosion_ring.tscn")

func set_player(player: Player) -> void:
	_player = player

func set_camera(camera: Camera2D) -> void:
	_camera = camera

func set_stone_count(count: int) -> void:
	_stone_count = count

func set_stone_display(display: Label) -> void:
	_stone_display = display

func _ready() -> void:
	question_ui.visible = false

func _process(_delta: float) -> void:
	if _question_asked:
		Global.game_paused = true
	if _player and _camera and _stone_count != null and _stone_display and not _question_asked:
		var question_area: TileMapLayer = find_child("QuestionArea", true, false)
		var cell_pos: Vector2i = question_area.local_to_map(_player.bottom.global_position)
		var data: TileData = question_area.get_cell_tile_data(cell_pos)
		if data:
			if data.get_custom_data("ball_in"):
				_question_asked = true
				Global.game_paused = true
				await get_tree().create_timer(1.0).timeout
				var tween: Tween = create_tween()
				tween.set_ease(Tween.EASE_IN_OUT)
				tween.tween_property(_camera, "position", Vector2(0, -50), 1.5)
				await tween.finished
				await get_tree().create_timer(2.0).timeout
				var dialog: Dialog = _dialog_scene.instantiate()
				add_child(dialog)
				dialog.typing.type("This is the barrier.")
				await dialog.closed
				dialog = _dialog_scene.instantiate()
				add_child(dialog)
				dialog.typing.type("The humans must be living somewhere behind this.     \nWithout any freedom.")
				await dialog.closed
				dialog = _dialog_scene.instantiate()
				add_child(dialog)
				dialog.typing.type("You have collected a total of " + str(_stone_count) + " stones.")
				await dialog.closed
				dialog = _dialog_scene.instantiate()
				add_child(dialog)
				dialog.typing.type("Do you wish to repair the barrier?")
				await dialog.typing.finished
				question_ui.visible = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("continue"):
		var mouse_pos: Vector2 = get_viewport().get_mouse_position() - Vector2(
			h_box_container.global_position.x,
			h_box_container.global_position.y,
		)
		if question_ui.visible and Rect2(yes.get_rect()).has_point(mouse_pos):
			question_ui.visible = false
			if _question2_asked:
				var dialog: Dialog = _dialog_scene.instantiate()
				add_child(dialog)
				dialog.typing.type("I knew you would come to your senses.")
				await dialog.closed
			get_tree().call_group("game", "stop_music")
			await _stone_throw_animation()
			var fade: Fade = _fade_scene.instantiate()
			add_child(fade)
			fade.set_color(Color.WHITE)
			fade.duration = 0.3
			fade.register_callback_half(_barrier_repair)
			barrier_player.play()
		elif question_ui.visible and Rect2(no.get_rect()).has_point(mouse_pos):
			question_ui.visible = false
			if not _question2_asked:
				var dialog: Dialog = _dialog_scene.instantiate()
				add_child(dialog)
				dialog.typing.type("What??")
				await dialog.closed
				dialog = _dialog_scene.instantiate()
				add_child(dialog)
				dialog.typing.type("After all that work you don't want to repair the barrier?")
				await dialog.typing.finished
				question_ui.visible = true
				yes.text = "Nevermind, I do it"
				_question2_asked = true
			else:
				var dialog: Dialog = _dialog_scene.instantiate()
				add_child(dialog)
				dialog.typing.type(
					"You decide it would be better to free the humans instead of locking them down further.")
				await dialog.closed
				get_tree().call_group("game", "stop_music")
				await _stone_throw_animation()
				var fade: Fade = _fade_scene.instantiate()
				add_child(fade)
				fade.set_color(Color.WHITE)
				fade.duration = 0.3
				fade.register_callback_half(_barrier_destroy)

func _stone_throw_animation() -> void:
	Global.ending_active = true
	while _stone_count:
		_stone_count -= 1
		_stone_display.text = str(_stone_count)
		var stone_instance: StoneItem = _stone_scene.instantiate()
		add_child(stone_instance)
		stone_instance.set_target(barrier.position, 0.3)
		stone_instance.position = _player.bottom.global_position
		var tween: Tween = create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		var random_pos: Vector2 = stone_instance.position
		random_pos.x += randi_range(-20, 20)
		random_pos.y += randi_range(-20, 20)
		tween.tween_property(stone_instance, "position", random_pos, 0.3)
		await get_tree().create_timer(0.002).timeout

func _barrier_repair() -> void:
	barrier_before.visible = false
	barrier_after.visible = true
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_camera, "position", Vector2(0, -750), 3.0)
	await get_tree().create_timer(2.5).timeout
	var fade: Fade = _fade_scene.instantiate()
	add_child(fade)
	fade.duration = 0.5
	fade.register_callback_half(_to_credits)

func _to_credits(wait_time: float = 5.5) -> void:
	if wait_time:
		for child: Node in get_children():
			if is_instance_of(child, Fade):
				var fade: Fade = child
				fade.paused = true
		await get_tree().create_timer(wait_time).timeout
	get_tree().change_scene_to_file("res://scenes/credits.tscn")

func _barrier_destroy() -> void:
	barrier_before.visible = false
	barrier_destroyed.visible = true
	var explosion_ring: Sprite2D = _explosion_ring_scene.instantiate()
	explosion_ring.position = barrier.position
	add_child(explosion_ring)
	explosion_player.play()
	await get_tree().create_timer(4.0).timeout
	var fade: Fade = _fade_scene.instantiate()
	add_child(fade)
	fade.duration = 0.5
	fade.register_callback_half(func() -> void: _to_credits(2.0))
