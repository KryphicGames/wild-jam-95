extends Control

@onready var MusicPlayer = $Music

func _on_music_finished() -> void:
	MusicPlayer.playing = true
