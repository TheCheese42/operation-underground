extends Area2D
class_name EnergyPot

var _callback: Callable = func() -> void: pass

func register_callback(callback: Callable) -> void:
	_callback = callback

func unregister_callback() -> void:
	_callback = func() -> void: pass

func _ready() -> void:
	_move_up()

func _move_up() -> void:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", position - Vector2(0, 6), 1.0)
	tween.finished.connect(_move_down)

func _move_down() -> void:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", position + Vector2(0, 6), 1.0)
	tween.finished.connect(_move_up)

func _on_body_entered(body: Node2D) -> void:
	if is_instance_of(body, Player):
		_callback.call()
		queue_free()
