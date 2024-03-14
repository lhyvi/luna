class_name Phase extends Node2D

@onready var front_phase = $FrontPhase
@onready var shader: ColorRect = $Shader
@onready var back_phase = $BackPhase

var is_front: bool = true
var tween: Tween

func _ready():
	Debug.phase = self
	var shader_displacement_loop = self.create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	var shader_material := shader.get_material()
	shader_displacement_loop.tween_property(shader_material, "shader_parameter/b_displacement", Vector2(7.5, -1), .2)
	shader_displacement_loop.parallel().tween_property(shader_material, "shader_parameter/g_displacement", Vector2(-8.5, 1), .2)
	shader_displacement_loop.tween_property(shader_material, "shader_parameter/b_displacement", Vector2(8.5, 1), .2)
	shader_displacement_loop.parallel().tween_property(shader_material, "shader_parameter/g_displacement", Vector2(-7.5, -1), .2)

func get_front():
	if is_front:
		return front_phase
	return back_phase

func get_back():
	if is_front:
		return back_phase
	return front_phase

func close_phase():
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(shader.get_material(), "shader_parameter/strength", 0.0, .1)
	tween.tween_callback(open_phase)

func open_phase():
	is_front = not is_front
	Debug.is_front = is_front
	if is_front:
		move_child(back_phase, 0)
		move_child(shader, 1)
		move_child(front_phase, 2)
	else:
		move_child(front_phase, 0)
		move_child(shader, 1)
		move_child(back_phase, 2)
	Debug.change_phase.emit()
	
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(shader.get_material(), "shader_parameter/strength", 1.0, .1)

func _process(_delta):
	if Debug.player and not Debug.player.can_meow:
		return
	if Input.is_action_just_pressed("phase"):
		change_phase()

func change_phase():
	close_phase()
		
