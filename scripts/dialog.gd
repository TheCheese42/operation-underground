extends CanvasLayer
class_name Dialog

signal closed

@onready var typing: Typing = $MarginContainer/NinePatchRect/MarginContainer/Typing

func _ready() -> void:
	Global.game_paused = true

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("continue"):
		if not typing.is_running():
			Global.game_paused = false
			closed.emit()
			queue_free()
