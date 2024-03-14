class_name Loading extends Node

var next_scene_path: String
var done_loading: bool = false
var finished: bool = false
var sprite_frames: SpriteFrames
@onready var person_sprite2d: AnimatedSprite2D = $PersonSprite2D
@onready var color_rect: ColorRect = $ColorRect

func _ready():
	done_loading = false
	finished = false
	
	var tween = color_rect.create_tween()
	tween.tween_property(color_rect, "modulate", Color.TRANSPARENT, 1.0)
	await tween.finished
	if sprite_frames:
		person_sprite2d.sprite_frames = sprite_frames
		person_sprite2d.play("default")
		#print(sprite_frames)
	await get_tree().create_timer(10).timeout
	#print("done")

func _process(_delta):
	if not done_loading or finished:
		return
	if next_scene_path and ResourceLoader.load_threaded_get_status(next_scene_path) == ResourceLoader.THREAD_LOAD_LOADED:
		finished = true
		var tween = color_rect.create_tween()
		tween.tween_property(color_rect, "modulate", Color.WHITE, 1.0)
		await tween.finished
		Debug._loading_scene_finished(next_scene_path)
		


func _on_person_sprite_2d_animation_finished():
	done_loading = true
	person_sprite2d.play("loop")
