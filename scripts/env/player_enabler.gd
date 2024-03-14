extends Node2D

@export var enable_jump: bool = false
@export var enable_meow: bool = false
@export var enable_dash: bool = false
@export var enable_wall: bool = false


func _on_player_detector_player_entered(player):
	if enable_jump:
		player.can_jump = true
	if enable_meow:
		player.can_meow = true
	if enable_dash:
		player.can_dash = true
	if enable_wall:
		player.can_wall = true
