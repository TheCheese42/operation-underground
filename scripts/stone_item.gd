extends Sprite2D
class_name StoneItem

func _ready() -> void:
	_move_up()

func _move_up() -> void:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "offset", Vector2(0, 4), 1.0)
	tween.finished.connect(_move_down)

func _move_down() -> void:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "offset", Vector2(0, 0), 1.0)
	tween.finished.connect(_move_up)

func set_target(pos: Vector2, wait_time: float) -> void:
	await get_tree().create_timer(wait_time).timeout
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	var time: float = (abs(position.x - pos.x) + abs(position.y - pos.y)) * 0.005
	tween.tween_property(self, "position", pos, time)
	tween.finished.connect(_collected)

func _collected() -> void:
	get_tree().call_group("game", "collect_rock")
	queue_free()
