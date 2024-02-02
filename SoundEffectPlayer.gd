extends Node

# Menu
const BUTTON_SOUND = preload("res://assets/sounds/MI_SFX 17.wav")
const BUILDING_SOUND = preload("res://assets/sounds/splat2ogg-14668.mp3")
const ERROR = preload("res://assets/sounds/error.mp3")
const COINS = preload("res://assets/sounds/coins.mp3")
const LAVA_BURST = preload("res://assets/sounds/steam_burst-6822.mp3")
const EXPLOSION = preload("res://assets/sounds/explosion-91872.mp3")
const FIRE_SOUND = preload("res://assets/sounds/fire-sound-efftect-21991.mp3")

@onready var sound = $Sound
@onready var gold_sound = $GoldSound
@onready var lava_sound = $LavaSound
@onready var explosion_sound = $ExplosionSound
@onready var fire_sound = $FireSound
@onready var set_building = $SetBuilding
@onready var error_sound = $ErrorSound


func _ready():
	fire_sound.set_volume_db(-25.0)
	pass

func play_button_pressed():
	sound.stream = BUTTON_SOUND
	sound.play()
	
func play_building_pressed():
	set_building.stream = BUILDING_SOUND
	set_building.play()

func play_error():
	error_sound.stream = ERROR
	error_sound.play()

func play_cashflow():
	gold_sound.stream = COINS
	gold_sound.play()
	
func play_lava_burst():
	lava_sound.stream = LAVA_BURST
	lava_sound.play()
	
func play_explosion():
	explosion_sound.stream = EXPLOSION
	explosion_sound.play()
	
func play_burning():
	fire_sound.stream = FIRE_SOUND
	fire_sound.play()
	if (fire_sound.get_volume_db() <= -5):
		fire_sound.set_volume_db(fire_sound.get_volume_db() + 1)
			
func stop_burning():
	fire_sound.stream_paused = true
