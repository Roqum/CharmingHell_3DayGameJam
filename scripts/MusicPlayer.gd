extends Node


# Background Music
const AMBIENT_1 = preload("res://assets/music/Ambient 1.mp3")
const ACTION_1 = preload("res://assets/music/Action 1 (Loop).mp3")
const LIGHT_AMBIENCE_4 = preload("res://assets/music/Light Ambience 4.mp3")

@onready var music = $Music

func _ready():
	pass


func play_music(style: String):
	if style == "beautifull":
		music.stream = AMBIENT_1
		music.play()
	elif style == "dramatic":
		music.stream = ACTION_1
		music.play()
	elif style == "end":
		music.stream = LIGHT_AMBIENCE_4
		music.play()

