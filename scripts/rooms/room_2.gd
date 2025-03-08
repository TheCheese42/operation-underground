extends Node2D

var _player: Player
var _player_in_button_range: bool = false
var _current_player_tile: Vector2i = Vector2i.ZERO
var _puzzle_solved: bool = false

func _on_button_area_entered(_area: Area2D) -> void:
	_player_in_button_range = true

func _on_button_area_exited(_area: Area2D) -> void:
	_player_in_button_range = false

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("continue") and _player_in_button_range and not _puzzle_solved:
		var xo_layer: TileMapLayer = find_child("XOTiles", true, false)
		for cell_pos: Vector2i in xo_layer.get_used_cells():
			xo_layer.set_cell(cell_pos, 3, Vector2i(21, 9))

func set_player(player: Player) -> void:
	_player = player

func _process(_delta: float) -> void:
	if _player:
		var xo_layer: TileMapLayer = find_child("XOTiles", true, false)
		var tile_pos: Vector2i = xo_layer.local_to_map(_player.bottom.global_position)
		if tile_pos != _current_player_tile:
			_current_player_tile = tile_pos
			var data: TileData = xo_layer.get_cell_tile_data(tile_pos)
			if data and not _puzzle_solved:
				var value: int = data.get_custom_data("xo_stage")
				if value == 0:  # O
					xo_layer.set_cell(tile_pos, 3, Vector2i(22, 9))
				elif value == 1:  # A
					xo_layer.set_cell(tile_pos, 3, Vector2i(23, 9))
				elif value == 2:  # X
					pass  # X is last stage

		var all_green: bool = true
		for cell_pos: Vector2i in xo_layer.get_used_cells():
			var cell_data: TileData = xo_layer.get_cell_tile_data(cell_pos)
			if cell_data:
				if cell_data.get_custom_data("xo_stage") != 1:
					all_green = false
					break
		if all_green:
			var spikes: TileMapLayer = find_child("Spikes", true, false)
			_puzzle_solved = true
			if spikes:
				spikes.queue_free()
