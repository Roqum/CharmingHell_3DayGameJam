extends Panel

@onready var earned_gold = $EarnedGold

func _ready():
	pass

func _process(delta):
	if visible:
		earned_gold.set_text(str("Your earned ", global.score, " gold!"))
