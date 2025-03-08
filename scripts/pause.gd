extends CanvasLayer

@onready var continue_: Label = $MarginContainer/CenterContainer/VBoxContainer/Continue
@onready var back: Label = $MarginContainer/CenterContainer/VBoxContainer/Back
@onready var v_box_container: VBoxContainer = $MarginContainer/CenterContainer/VBoxContainer

func _ready() -> void:
	Global.game_paused = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		close()
	elif event.is_action_pressed("continue"):
		var mouse_pos: Vector2 = get_viewport().get_mouse_position() - Vector2(
			v_box_container.global_position.x,
			v_box_container.global_position.y,
		)
		if Rect2(continue_.get_rect()).has_point(mouse_pos):
			close()
		elif Rect2(back.get_rect()).has_point(mouse_pos):
			close()
			get_tree().change_scene_to_file("res://scenes/menu.tscn") 

func close() -> void:
	await get_tree().create_timer(0).timeout
	Global.game_paused = false
	queue_free()
