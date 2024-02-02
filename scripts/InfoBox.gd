extends Panel


func _on_close_button_pressed():
	SoundEffectPlayer.play_button_pressed()
	get_tree().paused = false
	visible = false
