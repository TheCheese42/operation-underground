extends Node2D

var _player: Player
var _player_in_button_range: bool = false
var _puzzle_solved: bool = false
var balls: Array[RigidBody2D]
var placed_balls: Array[RigidBody2D]

func _on_button_area_entered(_area: Area2D) -> void:
	_player_in_button_range = true

func _on_button_area_exited(_area: Area2D) -> void:
	_player_in_button_range = false

func set_player(player: Player) -> void:
	_player = player

func _ready() -> void:
	for ball: RigidBody2D in [$Ball, $Ball2, $Ball3, $Ball4]:
		balls.append(ball.duplicate())
		placed_balls.append(ball)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("continue") and _player_in_button_range and not _puzzle_solved:
		var holes_layer: TileMapLayer = find_child("Holes", true, false)
		for cell_pos: Vector2i in holes_layer.get_used_cells():
			holes_layer.set_cell(cell_pos, 3, Vector2i(21, 8))
		for ball: RigidBody2D in placed_balls:
			ball.queue_free()
		placed_balls.clear()
		for ball: RigidBody2D in balls:
			var dupe: RigidBody2D = ball.duplicate()
			add_child(dupe)
			placed_balls.append(dupe)

func _process(_delta: float) -> void:
	if _player:
		var holes_layer: TileMapLayer = find_child("Holes", true, false)
		for ball: RigidBody2D in placed_balls.duplicate():
			var tile_pos: Vector2i = holes_layer.local_to_map(ball.position)
			var data: TileData = holes_layer.get_cell_tile_data(tile_pos)
			if data and not _puzzle_solved:
				var value: bool = data.get_custom_data("ball_in")
				if not value:  # Not in
					holes_layer.set_cell(tile_pos, 3, Vector2i(22, 8))
					placed_balls.erase(ball)
					ball.linear_velocity = Vector2.ZERO
					var tween: Tween = create_tween()
					tween.set_ease(Tween.EASE_IN_OUT)
					tween.tween_property(ball, "scale", Vector2.ZERO, 0.4)
					tween.finished.connect(ball.queue_free)
		
		var all_green: bool = true
		for cell_pos: Vector2i in holes_layer.get_used_cells():
			var cell_data: TileData = holes_layer.get_cell_tile_data(cell_pos)
			if cell_data:
				if not cell_data.get_custom_data("ball_in"):
					all_green = false
					break
		if all_green:
			var spikes: TileMapLayer = find_child("Spikes", true, false)
			_puzzle_solved = true
			if spikes:
				spikes.queue_free()
