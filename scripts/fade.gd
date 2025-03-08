extends CanvasLayer
class_name Fade

@onready var rect: ColorRect = $ColorRect

var duration: float = 1.0  # Duration one-way in seconds
var skip_to_second_half: bool = false
var immediately_full_alpha: bool = false
var paused: bool = false
var _has_skipped: bool = false
var _time_since_start: float = 0.0
var _going_up: bool = true

var _callback: Callable = func() -> void: pass
var _callback_half: Callable = func() -> void: pass

func register_callback(callback: Callable) -> void:
	_callback = callback

func unregister_callback() -> void:
	_callback = func() -> void: pass

func register_callback_half(callback: Callable) -> void:
	_callback_half = callback

func unregister_callback_half() -> void:
	_callback_half = func() -> void: pass

func _ready() -> void:
	reset()
	if immediately_full_alpha:
		rect.color.a8 = 255

func reset() -> void:
	_time_since_start = 0.0
	_going_up = true
	rect.color.a8 = 0
	if _has_skipped:
		skip_to_second_half = false

func set_color(color: Color) -> void:
	var prev_alpha: int = rect.color.a8
	rect.color = color
	rect.color.a8 = prev_alpha

func _process(delta: float) -> void:
	if paused:
		return
	_time_since_start += delta
	if (_time_since_start > duration and _going_up) or skip_to_second_half:
		_has_skipped = true
		skip_to_second_half = false
		_going_up = false
		_time_since_start = 0.0
		_callback_half.call()
	elif _time_since_start > duration:
		_callback.call()
		queue_free()
	var progress: float = _time_since_start / duration
	var progress8: float = progress * 255
	if not _going_up:
		progress8 = 255 - progress8
	rect.color.a8 = round(progress8)
