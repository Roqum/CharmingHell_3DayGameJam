extends Control

@onready var score_lable = $ScoreLable
@onready var player_name = $PlayerName


func _ready():
	score_lable.set_text(str("Your Score: ", global.get_score()))

func _process(delta):
	pass


func _on_button_pressed():
	SoundEffectPlayer.play_button_pressed()
	get_tree().paused = false
	var name = player_name.text 
	if name == "":
		name = "unkown"
	global.set_score_id(await SilentWolf.Scores.save_score(name, global.get_score()).sw_save_score_complete)
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/leaderboard.tscn")


func _on_to_leaderboard_pressed():
	SoundEffectPlayer.play_button_pressed()
	global.set_score_id({"score_id": 0})
	get_tree().change_scene_to_file("res://scenes/leaderboard.tscn")
