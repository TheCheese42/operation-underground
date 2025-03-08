extends CanvasLayer

@onready var typing: Typing = $MarginContainer/VBoxContainer/Typing
@onready var image: TextureRect = $MarginContainer/VBoxContainer/Image
@onready var music_player_1: AudioStreamPlayer = $MusicPlayer1
@onready var music_player_2: AudioStreamPlayer = $MusicPlayer2

var fade_scene: PackedScene = load("res://scenes/fade.tscn")

func _ready() -> void:
	Global.game_paused = false
	var fade_instance: Fade = fade_scene.instantiate()
	fade_instance.immediately_full_alpha = true
	fade_instance.duration = 0.5
	fade_instance.skip_to_second_half = true
	add_child(fade_instance)
	await get_tree().create_timer(0.5).timeout
	typing.type("Long ago, two races ruled over Earth:\nMONSTERS and HUMANS.")
	typing.register_callback(_setup_2)
	await get_tree().create_timer(2.5).timeout
	music_player_1.play()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("continue") or Input.is_action_just_pressed("esc"):
		_setup_main_menu(true)

func _setup_2() -> void:
	await get_tree().create_timer(2.0).timeout
	var fade_instance: Fade = fade_scene.instantiate()
	fade_instance.duration = 0.5
	fade_instance.register_callback_half(_set_image_2)
	fade_instance.register_callback(_start_text_2)
	add_child(fade_instance)

func _set_image_2() -> void:
	image.texture = load("res://assets/textures/images/intro_2.png")
	typing.reset()
	typing.unregister_callback()

func _start_text_2() -> void:
	typing.type("One day, the humans lost a game of Rock paper scissors...")
	typing.register_callback(_setup_3)

func _setup_3() -> void:
	await get_tree().create_timer(2.0).timeout
	var fade_instance: Fade = fade_scene.instantiate()
	fade_instance.duration = 0.5
	fade_instance.register_callback_half(_set_image_3)
	fade_instance.register_callback(_start_text_3)
	add_child(fade_instance)

func _set_image_3() -> void:
	image.texture = load("res://assets/textures/images/intro_3.png")
	typing.reset()
	typing.unregister_callback()

func _start_text_3() -> void:
	typing.type("The monsters sealed the humans underground with a magic spell.")
	typing.register_callback(_setup_4)

func _setup_4() -> void:
	await get_tree().create_timer(2.0).timeout
	var fade_instance: Fade = fade_scene.instantiate()
	fade_instance.duration = 0.5
	fade_instance.register_callback_half(_set_image_4)
	fade_instance.register_callback(_start_text_4)
	add_child(fade_instance)

func _set_image_4() -> void:
	image.texture = null
	typing.reset()
	typing.unregister_callback()

func _start_text_4() -> void:
	typing.type("But that spell requires huge amounts of stone...")
	typing.register_callback(_setup_5)

func _setup_5() -> void:
	await get_tree().create_timer(2.0).timeout
	var fade_instance: Fade = fade_scene.instantiate()
	fade_instance.duration = 0.5
	fade_instance.register_callback_half(_set_image_5)
	fade_instance.register_callback(_start_text_5)
	add_child(fade_instance)
	music_player_1.volume_db += 5
	music_player_1.play()
	await get_tree().create_timer(1.0).timeout
	music_player_2.play()

func _set_image_5() -> void:
	image.texture = load("res://assets/textures/images/intro_5.png")
	typing.reset()
	typing.unregister_callback()

func _start_text_5() -> void:
	await get_tree().create_timer(3.0).timeout
	_setup_6()

func _setup_6() -> void:
	await get_tree().create_timer(2.0).timeout
	var fade_instance: Fade = fade_scene.instantiate()
	fade_instance.duration = 0.5
	fade_instance.register_callback_half(_set_image_6)
	fade_instance.register_callback(_start_text_6)
	add_child(fade_instance)

func _set_image_6() -> void:
	image.texture = null
	typing.reset()
	typing.unregister_callback()

func _start_text_6() -> void:
	typing.type("One hole and a few hundred meters later...")
	typing.register_callback(_setup_main_menu)

func _setup_main_menu(skip_wait: bool = false) -> void:
	if not skip_wait:
		await get_tree().create_timer(4.2).timeout
	var tween2: Tween = create_tween()
	tween2.set_ease(Tween.EASE_IN_OUT)
	tween2.tween_property(music_player_2, "volume_db", -80, 0.5)
	if not skip_wait:
		await get_tree().create_timer(0.5).timeout
	var tween1: Tween = create_tween()
	tween1.set_ease(Tween.EASE_IN_OUT)
	tween1.tween_property(music_player_1, "volume_db", -80, 0.5)
	var fade_instance: Fade = fade_scene.instantiate()
	fade_instance.duration = 0.5
	fade_instance.register_callback_half(func() -> void: _to_main_menu(skip_wait))
	add_child(fade_instance)

func _to_main_menu(skip_wait: bool = false) -> void:
	if not skip_wait:
		for node: Node in get_children():
			if is_instance_of(node, Fade):
				var fade: Fade = node
				fade.paused = true
		await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
