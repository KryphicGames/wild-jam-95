extends Node

enum Audio {
	UI,
	TWO,
	THREE
}

func play(file: String, type: Audio = Audio.UI):
	var sound
	match type:
		Audio.UI:
			sound = AudioStreamPlayer.new()
		Audio.TWO:
			sound = AudioStreamPlayer2D.new()
		Audio.THREE:
			sound = AudioStreamPlayer3D.new()
	
	self.add_child(sound)
	sound.stream = load(file)
	sound.connect("finished", _on_stream_finished)
	sound.playing = true

func _on_stream_finished():
	self.queue_free()


func _ready() -> void:
	print("[AudioManager] Audio Manager loaded.")
