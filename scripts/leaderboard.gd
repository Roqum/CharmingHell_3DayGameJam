extends Control

@onready var names = $Panel/Names
@onready var scores = $Panel/Scores
@onready var loading_scores = $Panel/LoadingScores
@onready var your_place = $YourPlace
@onready var placement = $Panel/Placement

const SCORE_LABEL_SETTING = preload("res://assets/score_label_setting.tres")

func _ready():
	await get_tree().create_timer(0.1).timeout	
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores().sw_get_scores_complete
	loading_scores.visible = false
	var counter = 1
	for score in sw_result.scores:
		var place: Label = Label.new()
		var name_label: Label = Label.new()
		var score_label: Label = Label.new()
		place.label_settings = SCORE_LABEL_SETTING
		name_label.label_settings = SCORE_LABEL_SETTING
		score_label.label_settings = SCORE_LABEL_SETTING
		place.set_text(str(counter, "."))
		name_label.set_text(str(score.player_name, ":"))
		score_label.set_text(str(score.score))
		placement.add_child(place)
		names.add_child(name_label)
		scores.add_child(score_label)
		counter += 1
	var placement = await SilentWolf.Scores.get_score_position(global.get_score_id()).sw_get_position_complete
	if !global.get_score_id():
		placement.position = 0
	your_place.set_text(str("Your Placement: ", placement.position))
	



func _on_button_pressed():
	SoundEffectPlayer.play_button_pressed()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
