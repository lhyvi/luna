class_name NarrationResource extends Resource

@export var text: String = ""
@export var delay: float = 0.5
@export var callback: Callable

func _init(_text: String = "", _delay: float = 0.5, _callback = null):
	text = _text
	delay = _delay
	if _callback:
		callback = _callback
