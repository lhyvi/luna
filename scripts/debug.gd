extends Node

signal change_phase()
signal level_end()

var current_scene
var loading_scene_preload = preload("res://scenes/loading.tscn")
var loading_scene
var next_scene_path = ""

var player: Player
var camera: Camera2D
var phase: Phase
var phased: bool = true
var is_front := true
var camera_bounds: CameraBounds



func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

func reset_phase():
	phased = true
	is_front = true
	camera_bounds = null
	phase = null
	camera = null
	player = null

## bus is bus name (e.g. "Master")
## volume is 0 -> 1
func set_volume(bus: String, volume: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus)
	AudioServer.set_bus_mute(bus_index, volume <= 0)
	AudioServer.set_bus_volume_db(bus_index, lerp(-40, 0, volume))

func get_volume(bus: String) -> float:
	var bus_index := AudioServer.get_bus_index(bus)
	#prints('audio', bus, AudioServer.get_bus_volume_db(bus_index))
	return inverse_lerp(-40, 0, AudioServer.get_bus_volume_db(bus_index))

func change_scene_to_file(path: String, sprite_frames: SpriteFrames = null):
	#print("CHANGE SCENE TO", path)
	reset_phase()
	
	next_scene_path = path
	ResourceLoader.load_threaded_request(next_scene_path)
	loading_scene = loading_scene_preload.instantiate()
	loading_scene.next_scene_path = next_scene_path
	loading_scene.sprite_frames = sprite_frames
	
	#loading_scene.finished = false
	
	current_scene.queue_free()
	
	get_tree().root.add_child(loading_scene)
	#print("Finished Loading Shit")

func _loading_scene_finished(next_scene_path):
	#print("Loading Scene Finished")
	assert(next_scene_path != "")

	var next_scene = ResourceLoader.load_threaded_get(next_scene_path)
	#print("next scene, ", next_scene)
	#print("path, ", next_scene_path)
	current_scene = next_scene.instantiate()
	var tree := get_tree()
	loading_scene.queue_free()
	tree.root.add_child(current_scene)
	tree.current_scene = current_scene




