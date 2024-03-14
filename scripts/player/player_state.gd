class_name PlayerState extends State

var player: Player
var is_invincible = false

func _name() -> String:
	return "PlayerState"

func setup(change_state_: Callable, player_: Player, state_manager_) -> void:
	self.change_state = change_state_
	self.player = player_
	self.state_manager = state_manager_

func moveX(modifier: float = 1):
	return player.moveX(modifier)

func is_moveX():
	return player.is_moveX()

func _anim():
	player.sprite.play(player.state._name())

func _handle_anim_finish():
	player.sprite.play(player.state._name())
