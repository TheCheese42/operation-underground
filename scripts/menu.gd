extends CanvasLayer

var fade_scene: PackedScene = load("res://scenes/fade.tscn")
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	var fade_instance: Fade = fade_scene.instantiate()
	fade_instance.immediately_full_alpha = true
	fade_instance.duration = 0.5
	fade_instance.skip_to_second_half = true
	add_child(fade_instance)
	animated_sprite_2d.play("default")

func _on_quit_button_pressed() -> void:
	var fade_instance: Fade = fade_scene.instantiate()
	fade_instance.duration = 0.5
	fade_instance.register_callback_half(get_tree().quit)
	add_child(fade_instance)

func _on_new_game_button_pressed() -> void:
	var fade_instance: Fade = fade_scene.instantiate()
	fade_instance.duration = 0.5
	fade_instance.register_callback_half(_new_game)
	add_child(fade_instance)

func _on_credits_button_pressed() -> void:
	var fade_instance: Fade = fade_scene.instantiate()
	fade_instance.duration = 0.5
	fade_instance.register_callback_half(_open_credits)
	add_child(fade_instance)

func _new_game() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _open_credits() -> void:
	get_tree().change_scene_to_file("res://scenes/credits.tscn")
