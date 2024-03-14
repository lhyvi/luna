class_name CameraBoundsChecker extends Area2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var shape_size = collision_shape.shape.get_rect().size
@onready var offset = collision_shape.shape.get_rect().size / 2

func _ready():
	area_exited.connect(_on_area_exited)

func _physics_process(_delta):
	if Debug.camera_bounds:
		return
	var self_rect := Rect2(global_position - offset, shape_size)
	for area in get_overlapping_areas():
		if not area is CameraBounds:
			continue

		var camera_bounds := area as CameraBounds

		if camera_bounds.bounds_rect.encloses(self_rect):
			enter_bounds(camera_bounds)

func enter_bounds(camera_bounds: CameraBounds):
	if Debug.camera_bounds:
		return
	Debug.camera_bounds = camera_bounds

func _on_area_exited(area:Area2D):
	if not area is CameraBounds:
		return
	var camera_bounds := area as CameraBounds
	if Debug.camera_bounds == camera_bounds:
		Debug.camera_bounds = null
