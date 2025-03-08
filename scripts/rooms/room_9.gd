extends Node2D

var _player: Player
var _puzzle_solved: bool = false

func set_player(player: Player) -> void:
	_player = player

func _process(_delta: float) -> void:
	if _player:
		var buttons_layer: TileMapLayer = find_child("Buttons", true, false)
		var tile_pos: Vector2i = buttons_layer.local_to_map(_player.bottom.global_position)
		var data: TileData = buttons_layer.get_cell_tile_data(tile_pos)
		if data and not _puzzle_solved:
			var value: bool = data.get_custom_data("plate_state")
			if not value:  # Off
				buttons_layer.set_cell(tile_pos, 3, Vector2i(22, 7))
		
		var all_green: bool = true
		for cell_pos: Vector2i in buttons_layer.get_used_cells():
			var cell_data: TileData = buttons_layer.get_cell_tile_data(cell_pos)
			if cell_data:
				if not cell_data.get_custom_data("plate_state"):
					all_green = false
					break
		if all_green:
			var spikes: TileMapLayer = find_child("Spikes", true, false)
			_puzzle_solved = true
			if spikes:
				spikes.queue_free()
			for green_tile: Vector2i in buttons_layer.get_used_cells():
				buttons_layer.set_cell(green_tile, 3, Vector2i(23, 7))
