extends ColorRect

func _ready():
	visible = true
	fade_out()

func fade_out():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 1.0)
	await tween.finished

func fade_in():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 1.0)
	await tween.finished
