extends Camera2D

func _ready():
	Debug.camera = self

func _physics_process(_delta):
	if Debug.player:
		global_position = Debug.player.global_position
	if Debug.camera_bounds:
		global_position = Debug.camera_bounds.clamp_position(global_position)
	pass
