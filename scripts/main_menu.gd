extends Control

@onready var story_text = $StoryText
@onready var main_buttons = $MainButtons

func _ready():
	MusicPlayer.play_music("beautifull")
	main_buttons.visible = true
	story_text.visible = false

func _on_button_start_pressed():
	SoundEffectPlayer.play_button_pressed()
	story_text.visible = true
	main_buttons.visible = false


func _on_button_exit_pressed():
	SoundEffectPlayer.play_button_pressed()
	get_tree().quit()


func _on_button_pressed():
	SoundEffectPlayer.play_button_pressed()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/game.tscn")
