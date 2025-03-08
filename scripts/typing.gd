extends Control
class_name Typing

signal finished

@onready var label: Label = $Label
@export var speed: float = 5.0  # Characters per second

var _text_left: Array[String] = []
var _time_since_last: float = 0.0

var _callback: Callable = func() -> void: pass

func register_callback(callback: Callable) -> void:
	_callback = callback

func unregister_callback() -> void:
	_callback = func() -> void: pass

func is_running() -> bool:
	if _text_left:
		return true
	return false

func reset() -> void:
	label.text = ""
	_text_left = []
	_time_since_last = 0.0

func type(text: String) -> void:
	reset()
	for char_: String in text:
		_text_left.append(char_)

func _process(delta: float) -> void:
	if not _text_left:
		return
	_time_since_last += delta
	if _time_since_last >= 1 / speed:
		_time_since_last = 0.0
		label.text += _text_left.pop_front()
		if not _text_left:
			_callback.call()
			finished.emit()
