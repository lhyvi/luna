class_name Narration extends RichTextLabel

func _ready():
	var old_size = size
	size = Vector2(0, old_size.y)
	var tween = self.create_tween()
	tween.tween_property(self, "size", old_size, 1).set_trans(Tween.TRANS_CUBIC)
	tween.tween_interval(.1)
	tween.tween_property(self, "global_position", global_position + Vector2(0, -32), 5).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(self, "modulate", Color.TRANSPARENT, 4).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(queue_free)

