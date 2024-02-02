extends Control


@onready var charm_label = $GameStats/CharmLabel
@onready var gold_label = $GameStats/GoldLabel
@onready var villagers_label = $GameStats/VillagersLabel
@onready var placement_error_label: Label = $PlacementError
@onready var animation_player = $AnimationPlayer
@onready var info_box = $InfoBox


func _ready():
	pass
	
func update_charm_label(charm):
	charm_label.set_text(str("CHARM: ", charm))

func update_gold_label(gold):
	gold_label.set_text(str("GOLD: ", gold))
	
func update_villagers_label(villagers, max_villagers):
	villagers_label.set_text(str("VILLAGERS: ", villagers, "/", max_villagers))
	
func placement_error(message):
	placement_error_label.set_text(message)
	animation_player.play("NoVillagersSpace")
	animation_player.get_animation("NoVillagersSpace")


func _on_button_pressed():
	SoundEffectPlayer.play_button_pressed()
	get_tree().change_scene_to_file("res://scenes/your_score_view.tscn")


func _on_button_2_pressed():
	SoundEffectPlayer.play_button_pressed()
	info_box.visible = true
	get_tree().paused = true
