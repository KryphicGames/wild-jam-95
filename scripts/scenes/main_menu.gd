extends Control

@onready var MusicPlayer = $Music
@onready var Fade = $Fade/AnimationPlayer

func _ready():
	Fade.play("fade-in")

func _on_music_finished() -> void:
	MusicPlayer.playing = true
