class_name PhaseComponent extends Node

signal enable_phase()
signal disable_phase()

var enabled := true

var is_front: bool = true
var is_persist: bool = false

func _ready():
	Debug.change_phase.connect(_on_change_phase)
	setup_phase()
	
	update_phase()


func _on_change_phase():
	update_phase()

func setup_phase():
	var root := get_tree().root
	var parent = get_parent()
	
	is_persist = true
	while parent and parent != root:
		if parent is FrontPhase:
			is_front = true
			is_persist = false
			break
		elif parent is BackPhase:
			is_front = false
			is_persist = false
			break
		parent = parent.get_parent()

func update_phase():
	if is_persist:
		return
	
	if is_front == Debug.is_front:
		enable_phase.emit()
		enabled = true
	else:
		disable_phase.emit()
		enabled = false
