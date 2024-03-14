class_name Buffer extends RefCounted

const DEFAULT_BUFFER_MAX = .08
var buffer_max: float = DEFAULT_BUFFER_MAX:
	set(new_buffer_max):
		buffer_max = new_buffer_max
		if _buffer:
			_buffer.wait_time = buffer_max
var _buffer: Timer

func _init(parent: Node, buffer_max_: float = DEFAULT_BUFFER_MAX) -> void:
	self.buffer_max = buffer_max_
	_buffer = Timer.new()
	_buffer.wait_time = buffer_max_
	_buffer.autostart = true
	_buffer.one_shot = true
	parent.add_child(_buffer)
	
func reset():
	_buffer.start()

func disable() -> Buffer:
	_buffer.stop()
	return self

## Buffer returns true if input is true and *buffer is still running*
func buffer(input: bool = true) -> bool:
	return not _buffer.is_stopped() and input

func queue_free() -> void:
	_buffer.queue_free()
