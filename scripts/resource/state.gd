class_name State extends RefCounted

var state_manager
var change_state: Callable

func _name() -> String:
	return "State"

# Example setup function
# func setup(change_state: Callable, parent, state_manager) -> void:
# 	self.change_state = change_state
# 	self.parent = parent
# 	self.state_manager = state_manager

## Virtual Function
## Called when change_state to *this* state
func _start(_msg: Dictionary) -> void:
	pass

## Virtual Function
## Called when change_state to another state
func _end() -> Dictionary:
	return {}

## Virtual Function
## Called when animation is finished
func _handle_finish() -> void:
	pass

## Virtual Function
## Called every process frame
func _handle_input() -> void:
	pass

## Virtual Function
## Called every physics frame
func _update() -> void:
	pass
