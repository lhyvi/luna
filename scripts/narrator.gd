@tool
class_name Narrator extends Node2D

@export var is_enabled: bool = true
@export var narration: PackedScene
@export var narration_offset: Vector2
@export_range(0,5) var narration_delay: float = 3.0
@export_range(0,3) var narration_end_delay: float = 2.0
@export var narrations = [
	"Hello There",
	"Welcome to NUG",
	"Press A and D",
	"To Move",
	"Press W",
	"To Jump On Floors",
	"And Walls"
]

@export_subgroup("Debug")
@export_multiline var debug_narration = ""
@export var add_debug_narration: bool = false:
	set(_value):
		print("PRESSED", debug_narration)
		print(narrations)
		narrations.append(debug_narration)
		pass

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var narrate_buffer: Buffer
var is_narrating: bool = false

func _ready():
	if Engine.is_editor_hint():
		return
	narrate_buffer = Buffer.new(self, narration_delay)

var i = 0
func _process(_delta):
	if Engine.is_editor_hint():
		return
	if is_enabled and is_narrating and not narrate_buffer.buffer():
		narrate_buffer.reset()
		narrate(narrations[i])
		i = (i + 1) % narrations.size()
		if i == 0:
			await get_tree().create_timer(narration_end_delay).timeout
			narrate_buffer.reset()

func narrate(text: String):
	audio_stream_player.play()
	var n_instance := narration.instantiate() as Narration
	n_instance.text = "[center]" + text
	n_instance.global_position.x -= n_instance.size.x / 2
	n_instance.global_position += narration_offset
	add_child(n_instance)

func enable():
	if is_enabled:
		return
	is_enabled = true
	enable_narration()
	pass

func enable_narration():
	is_narrating = true
	i = 0
	narrate_buffer.reset()

func _on_visible_on_screen_notifier_2d_screen_entered():
	enable_narration()


func _on_visible_on_screen_notifier_2d_screen_exited():
	is_narrating = false


func _on_player_detector_player_entered(_player):
	enable()
