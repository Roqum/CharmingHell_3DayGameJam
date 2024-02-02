extends Panel

func _ready():
	visible = false

func _process(delta):
	if (Input.is_action_just_pressed("escape_pause")):
		get_tree().paused = !get_tree().paused
		visible = get_tree().paused


func _on_resume_button_pressed():
	SoundEffectPlayer.play_button_pressed()
	get_tree().paused = false
	visible = false

func _on_surrender_button_pressed():
	SoundEffectPlayer.stop_burning()
	SoundEffectPlayer.play_button_pressed()
	get_tree().paused = true
	MusicPlayer.play_music("end")
	get_tree().change_scene_to_file("res://scenes/your_score_view.tscn")
