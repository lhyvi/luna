class_name Player extends CharacterBody2D

@export var can_jump: bool = true
@export var can_dash: bool = true
@export var can_meow: bool = true
@export var can_wall: bool = true
@export var can_move: bool = true

@export var speed: float = 120
@export var jump_height : float = 48
@export var jump_time_to_peak : float = .5
@export var jump_time_to_descent : float = .4
@export var wall_gravity: float = 64
@export var wallkick_time: float = .2
@export var dash_multiplier: float = 1.5
@export var dash_time: float = .6
@export var damage_time :float = .5

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = (((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0) / Engine.physics_ticks_per_second
@onready var fall_gravity : float = (((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0) / Engine.physics_ticks_per_second

@onready var jump_buffer: Buffer = Buffer.new(self).disable()
@onready var dash_buffer: Buffer = Buffer.new(self).disable()
@onready var invincibility_buffer: Buffer = Buffer.new(self, 1.0).disable()
@onready var step_buffer: Buffer = Buffer.new(self, 0.3).disable()

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var jump_audio_player: AudioStreamPlayer = $JumpAudioPlayer
@onready var step_audio_player: AudioStreamPlayer = $StepAudioPlayer

var state: PlayerState
var state_manager: PlayerStateManager
var input: PlayerInput = PlayerInput.new()
var is_facing_right := true
var is_body_right := true

var meow_i = 0 :
	set(i):
		meow_i = i % meows.size()
var meows: Array[AudioStreamMP3] = [
	preload("res://assets/audio/meow0.mp3"),
	preload("res://assets/audio/meow1.mp3"),
	preload("res://assets/audio/meow2.mp3")
]

func _ready():
	state_manager.change_state("Waking")
	Debug.player = self

func _process(_delta):
	input.update(self)
	state._handle_input()
	if Input.is_action_just_pressed("phase") and can_meow:
		audio_player.stream = meows[meow_i]
		meow_i += 1
		audio_player.play()

func _physics_process(_delta: float):
	state._update()
	move_and_slide()
	velocity.y = clampf(velocity.y, -256, 256)

func moveX(modifier: float = 1) -> bool:
	var out := is_moveX()
	velocity.x = input.movex * speed * modifier
	return bool(out)

func is_moveX() -> bool:
	if input.movex > 0:
		is_facing_right = true
		is_body_right = true
	elif input.movex < 0:
		is_facing_right = false
		is_body_right = false
	if "Wall" in state._name():
		is_facing_right = not is_facing_right
		
	sprite.flip_h = not is_facing_right
	return bool(input.movex)

func is_wallslide() -> bool:
		if is_on_wall() and is_moveX():
			var is_wall_right := get_wall_normal().x < 0
			var is_movex_right := input.movex > 0
			return is_wall_right == is_movex_right
		return false

func take_damage():
	state_manager.change_state("Damage")

func make_step():
	if step_buffer.buffer():
		return
	step_buffer.reset()
	step_audio_player.play()

func _on_animated_sprite_2d_animation_finished():
	if state:
		state._handle_anim_finish()
	pass # Replace with function body.

class PlayerInput extends RefCounted:
	var movex: int = 0
	var jumped: bool = false
	var jumping: bool = false
	var dashed: bool = false
	var dashing: bool = false
		
	func update(player: Player):
		movex = 0
		if player.can_move and Input.is_action_pressed("move_left"):
			movex += -1
		if player.can_move and Input.is_action_pressed("move_right"):
			movex += 1
		
		if player.can_move and Input.is_action_just_pressed("move_jump") and player.can_jump:
			player.jump_buffer.reset()
		if player.can_move and Input.is_action_just_pressed("move_dash") and player.can_dash:
			player.dash_buffer.reset()
		
		jumping = player.can_move and Input.is_action_pressed("move_jump") and player.can_jump
		dashing = player.can_move and Input.is_action_pressed("move_dash") and player.can_dash
		
		jumped = player.can_move and (Input.is_action_just_pressed("move_jump") or player.jump_buffer.buffer(jumping)) and player.can_jump
		dashed = player.can_move and (Input.is_action_just_pressed("move_dash") or player.dash_buffer.buffer(dashing)) and player.can_dash



