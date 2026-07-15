extends Control

@onready var MusicPlayer = $Music
@onready var Fade = $Fade/AnimationPlayer
@onready var FadeRect = $Fade

func _ready():
	FadeRect.show()
	Fade.play("fade-in")

func _on_music_finished() -> void:
	MusicPlayer.playing = true


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")


func _on_play_pressed() -> void:
	FadeRect.show()
	Fade.play("fade-out")
	await Fade.animation_finished
	get_tree().change_scene_to_file("res://scenes/game.tscn")
