extends Control

@onready var MusicPlayer = $Music
@onready var Fade = $Fade/AnimationPlayer
@onready var FadeRect = $Fade

func _ready():
	FadeRect.show()
	Fade.play("fade-in")

func _on_music_finished() -> void:
	MusicPlayer.playing = true
