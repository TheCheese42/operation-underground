extends Node

var game_paused: bool = false
var ending_active: bool = false

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		var mode: DisplayServer.WindowMode = DisplayServer.window_get_mode()
		if mode == DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
