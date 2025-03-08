extends CanvasLayer

@onready var v_box_container: VBoxContainer = $VBoxContainer
@onready var music_player: AudioStreamPlayer = $MusicPlayer
var fade_scene: PackedScene = load("res://scenes/fade.tscn")

func _ready() -> void:
	Global.game_paused = false
	var fade_instance: Fade = fade_scene.instantiate()
	fade_instance.immediately_full_alpha = true
	fade_instance.duration = 0.5
	fade_instance.skip_to_second_half = true
	add_child(fade_instance)
	var tween: Tween = create_tween()
	var target_position: Vector2 = Vector2(v_box_container.position)
	target_position.y -= v_box_container.size.y + 170
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(v_box_container, "position", target_position, 34.0)
	tween.finished.connect(_show_godot_icon)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("continue") or Input.is_action_just_pressed("esc"):
		_back_to_menu(true)

func _show_godot_icon() -> void:
	await get_tree().create_timer(1.0).timeout
	var icon: Sprite2D = Sprite2D.new()
	icon.texture = load("res://assets/textures/misc/godot.svg")
	add_child(icon)
	icon.position.x = v_box_container.size.x / 2
	icon.position.y = v_box_container.position.y + v_box_container.size.y + 50
	icon.scale = Vector2.ZERO
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(icon, "scale", Vector2(0.5, 0.5), 2.0)
	tween.finished.connect(_back_to_menu)

func _back_to_menu(skip_wait: bool = false) -> void:
	if not skip_wait:
		await get_tree().create_timer(5.0).timeout
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(music_player, "volume_db", -80, 0.5)
	var fade_instance: Fade = fade_scene.instantiate()
	fade_instance.duration = 0.5
	add_child(fade_instance)
	fade_instance.register_callback_half(
		func() -> void: get_tree().change_scene_to_file("res://scenes/menu.tscn")
	)
