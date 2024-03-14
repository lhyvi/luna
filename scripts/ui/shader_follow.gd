extends ColorRect

func _physics_process(_delta):
	if Debug.player:
		global_position = Debug.player.global_position - (size / 2)
