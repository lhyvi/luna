extends "res://scripts/env/player_enabler.gd"

@onready var player_detector: PlayerDetector = $PlayerDetector

func _ready():
	Debug.change_phase.connect(game_end)

var end = false
func game_end():
	if player_detector.player_inside and not end:
		end = true
		Debug.level_end.emit()
		#print("level end")
