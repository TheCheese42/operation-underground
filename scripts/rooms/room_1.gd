extends Node2D

var _player_in_button_range: bool = false

func _on_button_area_entered(_area: Area2D) -> void:
	_player_in_button_range = true

func _on_button_area_exited(_area: Area2D) -> void:
	_player_in_button_range = false

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("continue") and _player_in_button_range:
		var spikes: TileMapLayer = find_child("Spikes", true, false)
		if spikes:
			spikes.queue_free()
