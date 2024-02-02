extends Node

var score = 0
var score_id

func _ready():
	set_up_leaderboard()
	
func set_score(value):
	score = value

func get_score():
	return score

func set_up_leaderboard():
	SilentWolf.configure({
		"api_key": "ergsLfdYhM27dGAAKOu3y8mCqoywDCfka3MYYgKn",
		"game_id": "forthemoney",
		"log_level": 1
	})

	SilentWolf.configure_scores({
		"open_scene_on_close": "res://scripts/main_menu.gd"
	})

func set_score_id(result: Dictionary):
	score_id = result.score_id
	
func get_score_id():
	return score_id
