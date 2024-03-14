extends TileMap


var game_end := false

func _ready():
	tile_set = tile_set.duplicate()
	Debug.level_end.connect(_game_end)

func _game_end():
	game_end = true
	var back = Debug.phase.get_back()
	if get_parent() != back:
		reparent(back)
	_on_phase_component_disable_phase()

func _on_phase_component_enable_phase():
	if game_end:
		return
	tile_set.set_physics_layer_collision_layer(0, 1)
	pass # Replace with function body.


func _on_phase_component_disable_phase():
	tile_set.set_physics_layer_collision_layer(0, 0)
	pass # Replace with function body.
