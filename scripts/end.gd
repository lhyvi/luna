extends Node2D
@onready var label = $RichTextLabel
@onready var cat = $Cat

func _ready():
	label.modulate = Color.TRANSPARENT
	cat.modulate = Color.TRANSPARENT
	var tween = create_tween()
	tween.tween_interval(1)
	tween.tween_property(label, "modulate", Color.WHITE, 2)
	tween.tween_interval(1)
	tween.tween_property(cat, "modulate", Color.WHITE, 2)
