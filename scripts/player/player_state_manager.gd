class_name PlayerStateManager extends Node2D

var player: Player

const color_default = Color.BLACK
const color_dash = Color.WHITE

var states := {
	"Waking": WakingState,
	"Standing": StandingState,
	"Walking": WalkingState,
	"Dashing": DashingState,
	"Jumping": JumpingState,
	"Falling": FallingState,
	"WallSlide": WallSlideState,
	"Damage": DamageState,
}

func _ready():
	var parent = get_parent()
	if parent is Player:
		player = parent
		player.state_manager = self
	else:
		printerr("STATEMANAGER PARENT is '", parent, "' AND NOT PLAYER")
	
func change_state(new_state_name: String) -> void:
	var new_state
	if self.states.has(new_state_name):
		new_state = states[new_state_name].new()
	else:
		printerr("STATE: ", new_state_name, " CAN'T BE FOUND")
		return
	new_state.setup(change_state, player, self)

	var prev_name := ""
	var prev_state := player.state
	var msg := {}
	if prev_state:
		prev_name = prev_state._name()
		msg = prev_state._end()

	msg["prev_name"] = prev_name
	player.state = new_state
	new_state._anim()
	new_state._start(msg)

class WakingState extends PlayerState:
	func _name():
		return "Waking"
	
	func _handle_anim_finish():
		change_state.call("Standing")

class StandingState extends PlayerState:
	func _name():
		return "Standing"
	
	func _start(_msg):
		player.velocity.y = 0
	
	func _handle_input():
		var input := player.input
		
		if input.dashed:
			change_state.call("Dashing")
		elif is_moveX():
			change_state.call("Walking")
		elif not player.is_on_floor():
			change_state.call("Falling")
		elif input.jumped:
			change_state.call("Jumping")
		
	func _update():
		moveX()
		player.velocity.y += 1 # Add 1 for better tile detection
	

class WalkingState extends StandingState:
	func _name():
		return "Walking"
	
	func _start(msg):
		super(msg)
	
	func _end():
		return {}
		
	func _handle_input():
		var input := player.input
		if not is_moveX():
			change_state.call("Standing")
		elif input.dashed:
			change_state.call("Dashing")
		if input.jumped:
			change_state.call("Jumping")
		elif not player.is_on_floor():
			change_state.call("Falling")
	
	func _update():
		player.make_step()
		moveX()
		player.velocity.y += 1
	

class DashingState extends StandingState:
	var dash_timer_buffer: Buffer
	var msg := {}
	
	func _name():
		return "Dashing"
		
	func _start(_msg):
		dash_timer_buffer = Buffer.new(player, player.dash_time)
		player.modulate = color_dash
	
	func _end():
		player.modulate = color_default
		dash_timer_buffer.queue_free()
		return msg
	
	func _handle_input():
		var input := player.input
		
		if not dash_timer_buffer.buffer(true) or not input.dashing:
			change_state.call("Walking")
		if input.jumped:
			msg["dash"] = true
			change_state.call("Jumping")
		elif not player.is_on_floor():
			msg["dash"] = true
			change_state.call("Falling")
	
	func _update():
		is_moveX()
		player.velocity.x = (player.speed * player.dash_multiplier) if player.is_body_right else -(player.speed * player.dash_multiplier)


class JumpingState extends PlayerState:
	var cspeed = 1.0
	var wallkick_buffer: Buffer
	var kick_right := true
	var _dash := false
	var msg_out := {}

	func _name():
		return "Jumping"
	
	func _anim():
		player.sprite.play("Jump")
	
	func kick(kick_right_) -> JumpingState:
		wallkick_buffer = Buffer.new(player, player.wallkick_time)
		self.kick_right = kick_right_
		return self
	
	func enable_dash():
		player.modulate = color_dash
		_dash = true
		cspeed = player.dash_multiplier
	
	func _start(msg):
		player.jump_audio_player.play()
		player.velocity.y = player.jump_velocity

		if msg.has("kick"):
			kick(msg["kick"])
		if msg.has("dash"):
			enable_dash()

	func _end():
		if wallkick_buffer:
			wallkick_buffer.queue_free()
		player.modulate = color_default
		return msg_out
	
	func _handle_input():
		if not player.input.jumping or player.velocity.y > 0:
			msg_out["jump"] = false
			if _dash:
				msg_out["dash"] = true
			change_state.call("Falling")

		if player.is_on_floor():
			if is_moveX():
				change_state.call("Walking")
			else:
				change_state.call("Standing")

		if _dash and not player.input.dashing:
			player.modulate = color_default
			_dash = false
			cspeed = 1.0
	
	func _update():
		if wallkick_buffer and wallkick_buffer.buffer(true):
			player.is_facing_right = kick_right
			player.velocity.x = player.speed * cspeed if kick_right else -player.speed * cspeed
		else:
			moveX(cspeed)
		player.velocity.y += player.jump_gravity
	

class FallingState extends PlayerState:
	var fall_jump_buffer: Buffer
	var cspeed: float = 1.0
	var kick_right := true
	var _kick := false
	var _dash := false
	var on_wall := false
	var msg_out := {}

	func _name():
		return "Falling"
	
	func disable_jump():
		fall_jump_buffer.disable()
		return self
	
	func enable_dash():
		player.modulate = color_dash
		_dash = true
		cspeed = player.dash_multiplier
	
	func kick(kick_right_):
		self._kick = true
		self.kick_right = kick_right_
		return self
	
	func _start(msg):
		if player.velocity.y < 0:
			player.velocity.y /= 2
			
		fall_jump_buffer = Buffer.new(player)

		if msg.has("kick"):
			kick(msg["kick"])
		if msg.has("dash"):
			enable_dash()
		if msg.has("jump") and msg["jump"] == false:
			disable_jump()
	
	func _end():
		fall_jump_buffer.queue_free()
		player.modulate = color_default
		return msg_out 
	
	func _handle_input():
		var input := player.input	
		if fall_jump_buffer.buffer(input.jumped):
			if _kick:
				msg_out["kick"] = kick_right
				
			if _dash:
				msg_out["dash"] = true
			change_state.call("Jumping")
			return

		if input.jumped and player.is_on_floor():
			change_state.call("Jumping")
			return
		elif player.is_on_floor():
			if is_moveX():
				change_state.call("Walking")
			else:
				change_state.call("Standing")
		elif player.can_wall and player.is_wallslide():
			var is_wall_right := player.get_wall_normal().x < 0
			var is_movex_right := player.input.movex > 0

			if is_wall_right == is_movex_right:
				change_state.call("WallSlide")
		
		if _dash and not player.input.dashing:
			player.modulate = color_default
			_dash = false
			cspeed = 1.0
	
	func _update():
		moveX(cspeed)
		on_wall = player.is_on_wall()
		player.velocity.y += player.fall_gravity
	

class WallSlideState extends PlayerState:
	var kick_right := true
	var msg_out := {}
	
	func _name():
		return "WallSlide"

	func _start(_msg):
		is_moveX()
		assert(player.input.movex)
		kick_right = player.input.movex == -1
	
	func _end():
		return msg_out
	
	func _handle_input():
		if not player.is_wallslide():
			msg_out["kick"] = kick_right
			if player.input.dashing:
				msg_out["dash"] = true
			change_state.call("Falling")
			return
		if player.input.jumped:
			msg_out["kick"] = kick_right
			if player.input.dashing:
				msg_out["dash"] = true
			change_state.call("Jumping")
			return
		if player.is_on_floor():
			change_state.call("Standing")

	func _update():
		moveX()
		player.velocity.y = player.wall_gravity
	

class DamageState extends PlayerState:
	var damage_buffer: Buffer
	
	func _name():
		return "Damage"

	func _init():
		is_invincible = true
	
	func _start(_msg):
		player.velocity.y = player.jump_velocity / 2
		damage_buffer = Buffer.new(player, player.damage_time)
	
	func _end():
		damage_buffer.queue_free()
		player.invincibility_buffer.reset()
		return {}
	
	func _handle_input():
		if not damage_buffer.buffer(true):
			if player.is_on_floor():
				if player.input.jumped:
					change_state.call("Jumping")
				else:
					change_state.call("Standing")
			else:
				change_state.call("Falling")
	
	func _update():
		player.velocity.x =  -player.speed / 2 if player.is_body_right else player.speed / 2
		player.velocity.y += player.fall_gravity


