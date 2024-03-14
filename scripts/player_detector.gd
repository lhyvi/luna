class_name PlayerDetector extends Area2D

signal player_entered(player)
signal player_exited(player)
var player_inside := false

func _ready():
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	player_entered.emit(body)
	player_inside = true


func _on_body_exited(body):
	player_exited.emit(body)
	player_inside = false
