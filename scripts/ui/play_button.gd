extends Button

@onready var main_scene: PackedScene
@export var sprite_frames: SpriteFrames

func _on_pressed():
	Debug.change_scene_to_file("res://scenes/levels/lvl01.tscn", sprite_frames)
