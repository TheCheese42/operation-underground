extends Sprite2D

func _ready() -> void:
	scale = Vector2.ZERO
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2(100.0, 100.0), 2.0)
	tween.finished.connect(queue_free)
