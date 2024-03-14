extends Node2D

@export_file("*.tscn") var next_scene = "res://scenes/levels/lvl01.tscn"
@export var sprite_frames: SpriteFrames = null

@onready var game_end_audio: AudioStreamPlayer = $GameEndAudio

func _ready():
	visible = false
	Debug.level_end.connect(_on_phase_component_enable_phase)

func _process(delta):
	if not visible:
		return
	if Debug.player:
		global_position = Debug.player.global_position

func _on_phase_component_enable_phase():
	visible = true
	fade_in()
	pass # Replace with function body.

func fade_in():
	game_end_audio.play()
	var tween = self.create_tween()
	modulate = Color.TRANSPARENT
	tween.tween_interval(3)
	tween.tween_property(self, "modulate", Color.WHITE, 3).set_trans(Tween.TRANS_SINE)
	tween.tween_interval(3)
	tween.tween_callback(_next_scene)

var end = false

func _next_scene():
	if not end:
		end = true
		Debug.change_scene_to_file(next_scene, sprite_frames)
