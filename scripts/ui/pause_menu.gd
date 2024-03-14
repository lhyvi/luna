extends Control

@onready var sprite: Sprite2D = $Sprite2D
@onready var music_slider: HSlider = $MusicSlider
@onready var volume_slider: HSlider = $VolumeSlider

const offset = Vector2(-120, -90)
const SHRINK_SCALE = Vector2(0.5, 0.5)

func _ready():
	visible = false
	volume_slider.value = Debug.get_volume("SFX") * 100
	music_slider.value = Debug.get_volume("Music") * 100

func _process(_delta):
	var tree := get_tree()
	if Input.is_action_just_pressed("pause"):
		if not tree.paused:
			pause()
		else:
			unpause()
	
	if tree.paused:
		Debug.set_volume("SFX", volume_slider.value / 100)
		Debug.set_volume("Music", music_slider.value / 100)

var tween: Tween

func toggle_pause():
	var tree := get_tree()
	tree.paused = not tree.paused

func pause():
	visible = true
	scale = Vector2.ONE
	
	if tween:
		tween.kill()
	var viewport := get_viewport()
	assert(viewport)
	
	var image := viewport.get_texture().get_image()
	image.resize(240, 180)
	sprite.texture = ImageTexture.create_from_image(image)
	if Debug.camera:
		global_position = Debug.camera.get_screen_center_position() + offset
		#tween = self.create_tween()
		#tween.tween_property(self, "global_position", Debug.camera.get_screen_center_position(), 1).set_trans(Tween.TRANS_SINE)
		#tween.tween_callback(shrink)
	elif Debug.player:
		global_position = Debug.player.global_position + offset
		#tween = self.create_tween()
		#tween.tween_property(self, "global_position", Debug.player.global_position, 1).set_trans(Tween.TRANS_SINE)
		#tween.tween_callback(shrink)
	shrink()
	toggle_pause()

func shrink():
	if tween:
		tween.kill()
	tween = sprite.create_tween()
	tween.tween_property(sprite, "scale", SHRINK_SCALE, .5).set_trans(Tween.TRANS_SINE)

func unpause():
	unshrink()
	pass

func unshrink():
	if tween:
		tween.kill()
	tween = sprite.create_tween()
	tween.tween_property(sprite, "scale", Vector2.ONE, .5).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(unshrink_end)

func unshrink_end():
	visible = false
	toggle_pause()
