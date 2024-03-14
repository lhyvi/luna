@tool
class_name CameraBounds extends Area2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
var top_left: Vector2 = Vector2.ZERO
var bottom_right: Vector2 = Vector2.ZERO
var bounds_rect: Rect2 = Rect2()

@export_group("debug")

@export var update_bounds: bool:
	set(_val):
		print("update bounds")
		setup_position()
		update_configuration_warnings()

func clamp_position(pos: Vector2):
	return pos.clamp(top_left, bottom_right)

func setup_position():
	if collision_shape.position.x or collision_shape.position.y:
			position += collision_shape.position
			collision_shape.position = Vector2.ZERO

func _ready():
	setup_position()
	var clamp_size = Vector2(collision_shape.shape.size - get_viewport_rect().size)
	if clamp_size.x < 0:
		clamp_size.x = 0
	if clamp_size.y < 0:
		clamp_size.y = 0
	var corner_offset = clamp_size / 2
	bottom_right = position + corner_offset
	top_left = position - corner_offset
	bounds_rect = Rect2(collision_shape.global_position, collision_shape.shape.get_rect().size)
	bounds_rect.position -= bounds_rect.size / 2
	pass

func _process(_delta):
	if not Engine.is_editor_hint():
		return
	if not collision_shape:
		return
	if collision_shape.position.x or collision_shape.position.y:
		update_configuration_warnings()

func _get_configuration_warnings():
	var warnings = []
	# var new_size := Vector2(collision_shape.shape.size - get_viewport_rect().size)
	if collision_shape.position.x or collision_shape.position.y:
		warnings.append("Need Update Bounds")
	return []
