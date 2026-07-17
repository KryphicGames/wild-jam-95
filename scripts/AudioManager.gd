extends Node

@export var debugPrefix = "AudioManager"

enum Audio {
	UI,
	TWO,
	THREE
}

func play(
	file: String,
	type: Audio = Audio.UI,
	volume_db: float = 0.0,
	pitch_scale: float = 1.0
) -> void:
	if !ResourceLoader.exists(file):
		Log.Warn("Audio resource does not exist: " + file, debugPrefix)
		return

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
	sound.volume_db = volume_db
	sound.pitch_scale = pitch_scale
	sound.finished.connect(_on_stream_finished.bind(sound))
	sound.playing = true


func _on_stream_finished(sound: Node) -> void:
	sound.queue_free()


func _ready() -> void:
	Log.Info("AudioManager loaded successfully.", debugPrefix)
