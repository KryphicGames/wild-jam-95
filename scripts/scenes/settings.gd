extends Control

@onready var MusicPlayer = $Music

func _on_music_finished() -> void:
	MusicPlayer.playing = true


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
