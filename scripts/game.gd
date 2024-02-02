extends Node2D

# Tilemap Layers
const ground_tiles_layer = 2
const placements_tiles_layer = 3
const selector_layer = 4
const selector_validator_layer = 5
const destroyed_selector_layer = 7
const got_hit_selector = 6
###

# Selector Types
const valid_placement = {"source_id": 4, "image_cords": Vector2i(21,4)}
const invalid_placement = {"source_id": 4, "image_cords": Vector2i(22,4)}
###

# Buildings tiles
const small_house = {"source_id": 2, "image_cords": Vector2i(27,26)}
const medium_house = {"source_id": 2, "image_cords": Vector2i(15,31)}
const big_house = {"source_id": 2, "image_cords": Vector2i(29,31)}
const church = {"source_id": 2, "image_cords": Vector2i(22,38)}
const mine = {"source_id": 4, "image_cords": Vector2i(19,5)}
const castle = {"source_id": 4, "image_cords": Vector2i(12,26)}
###

const fire_tile = {"source_id": 1, "image_cords": Vector2i(14,2)}
const lava_fall = {"source_id": 4, "image_cords": Vector2i(4,22)}

const building = ["small_house", "medium_house", "big_house", "church", "castle", "mine"]
const invalid_placement_terrain = ["river", "sea", "ocean", "lava"]

@onready var tile_map = $TileMap
@onready var ui = $UI
@onready var timer : Timer = $Timer
@onready var gold_income_timer = $GoldIncomeTimer
@onready var losing_screen = $UI/LosingScreen

var current_lava_rivers: Array[Vector2i] = []

var is_building = false
var selected_building = null
var building_placed: Dictionary = {}

var number_of_disasters_at_once = 2
var time_until_next_disaster = 8
var disaster_counter = 0

var total_charm = 0
var total_gold = 100
var gold_income = 0
var max_villagers = 0
var total_villagers = 0

var map_data: Dictionary
var selector_tile = Vector2i(22,5)
var rng = RandomNumberGenerator.new()

func _ready():
	losing_screen.visible = false
	gold_income_timer.start(5)
	gold_income_timer.timeout.connect(get_gold)
	timer.start(time_until_next_disaster)
	timer.timeout.connect(initiate_round)
	update_ui()

func _process(delta):
	global.set_score(total_gold)
	calculate_total_charm_gold()
	if losing_screen:
		check_for_lose()
	update_ui()
	
func _input(event):
	if is_building:
		var selected_field = tile_map.local_to_map(get_global_mouse_position())
		tile_map.clear_layer(selector_layer)
		tile_map.set_cell(selector_layer, selected_field, selected_building.source_id, selected_building.image_cords)
		if is_placement_valid() && Input.is_action_just_pressed("mouse_click_left"):
			if (!no_gold_to_pay() && !is_max_villagers_exceeded()):
				SoundEffectPlayer.play_building_pressed()
				clear_current_building_selection()
				tile_map.set_cell(placements_tiles_layer, selected_field, selected_building.source_id, selected_building.image_cords)
				var bulding: TileData =  tile_map.get_cell_tile_data(placements_tiles_layer, selected_field)
				total_gold -= bulding.get_custom_data("GoldCost")
			else:
				SoundEffectPlayer.play_error()
		elif !is_placement_valid() && Input.is_action_just_pressed("mouse_click_left"):
			SoundEffectPlayer.play_error()
		elif Input.is_action_just_pressed("mouse_button_right"):
			clear_current_building_selection()
func update_ui():
	ui.update_charm_label(total_charm)
	ui.update_gold_label(total_gold)
	ui.update_villagers_label(total_villagers, max_villagers)
	
func placement_error(message: String):
	ui.placement_error(message)

func get_random_cell():
	var x = rng.randi_range(0,24)
	var y = rng.randi_range(0,13)
	return Vector2i(x,y)

func initiate_round():
	initiate_disaster()
	
func initiate_disaster():
	disaster_counter += 1
	if disaster_counter % 3 == 0:
		number_of_disasters_at_once += 1
	if disaster_counter == 10:
		time_until_next_disaster = 5
		timer.start(time_until_next_disaster)
	if disaster_counter == 20:	
		MusicPlayer.play_music("dramatic")
		time_until_next_disaster = 3
		timer.start(time_until_next_disaster)
		
	tile_map.clear_layer(got_hit_selector)
	SoundEffectPlayer.play_explosion()
	
	advance_lava_rivers()		
	for n in number_of_disasters_at_once:
		var valid_disaster_fields = tile_map.get_used_cells(1)
		var random_cell_index: int = rng.randi_range(1,valid_disaster_fields.size() - 1)
		
		var tile_ground: TileData = tile_map.get_cell_tile_data(2, valid_disaster_fields[random_cell_index])
		var tile_placement: TileData = tile_map.get_cell_tile_data(3, valid_disaster_fields[random_cell_index])
		if(!tile_placement && tile_ground.get_custom_data("TerrainType") == "grass"):
			tile_map.set_cell(got_hit_selector, valid_disaster_fields[random_cell_index], 0, Vector2i(22,4))
			
		elif(tile_placement):
			var terrain_type = tile_placement.get_custom_data("TerrainType")
			tile_map.set_cell(got_hit_selector, valid_disaster_fields[random_cell_index], 0, Vector2i(22,4))
			if terrain_type == "mountain" || terrain_type == "mine":
				tile_map.set_cell(placements_tiles_layer, valid_disaster_fields[random_cell_index], lava_fall.source_id, lava_fall.image_cords)
				current_lava_rivers.append(valid_disaster_fields[random_cell_index])
			elif terrain_type == "stone" || terrain_type == "small_tree":
				tile_map.erase_cell(placements_tiles_layer, valid_disaster_fields[random_cell_index])
			elif terrain_type == "tree" || building.has(terrain_type):
				SoundEffectPlayer.play_burning()
				tile_map.set_cell(destroyed_selector_layer, valid_disaster_fields[random_cell_index], fire_tile.source_id, fire_tile.image_cords)

func calculate_total_charm_gold():
	var charm_sum = 0
	var villagers_sum = 0
	var placements_on_map = tile_map.get_used_cells(placements_tiles_layer)
	building_placed.clear()
	for placement in placements_on_map:
		var tile: TileData = tile_map.get_cell_tile_data(placements_tiles_layer, placement)
		if (!tile_map.get_cell_tile_data(destroyed_selector_layer, placement)):
			if building.has(tile.get_custom_data("TerrainType")):
				building_placed[placement] = null
			charm_sum += tile.get_custom_data("CharmValue")
			villagers_sum += tile.get_custom_data("Villagers")
	total_charm = charm_sum
	total_villagers = villagers_sum
	calculate_max_villagers()

func check_for_lose():	
	if building_placed.size() == 0:
		MusicPlayer.play_music("end")
		SoundEffectPlayer.stop_burning()
		losing_screen.visible = true
		get_tree().paused = true
	
func advance_lava_rivers():
	var new_lava_fields: Array[Vector2i] = []
	for river in current_lava_rivers:
		var is_lava_growing = rng.randfn(1)
		if is_lava_growing < -1 || is_lava_growing > 3:
			continue
		var path: Array[Vector2i] = []
		var next_lava_field = river + Vector2i(0,1)
		path.append(river)
		path.append(next_lava_field)
		var next_tile: TileData = tile_map.get_cell_tile_data(ground_tiles_layer, next_lava_field)
		if next_tile:
			if (next_tile.get_custom_data("TerrainType") != "ocean" && next_tile.get_custom_data("TerrainType") != "sea"):
				new_lava_fields.append(next_lava_field)
				tile_map.set_cells_terrain_path(ground_tiles_layer, path, 0, 1)
				if tile_map.get_cell_tile_data(placements_tiles_layer, next_lava_field):
					SoundEffectPlayer.play_lava_burst()
				tile_map.erase_cell(placements_tiles_layer, next_lava_field)
				tile_map.erase_cell(destroyed_selector_layer, next_lava_field)
	current_lava_rivers.clear()
	current_lava_rivers = new_lava_fields
		
func is_placement_valid():
	if (!selected_building):
		return false
	tile_map.clear_layer(selector_validator_layer)	
	var placement_pattern = [Vector2i(0,0)]
	if (selected_building == church || selected_building == big_house):
		placement_pattern = [Vector2i(0,0), Vector2i(0,-1)]		
	elif(selected_building == castle):
		placement_pattern = [Vector2i(0,0), Vector2i(0,1), Vector2i(1,1), Vector2i(1,0)]
		
	var all_valid = true
	for cell in placement_pattern:
		var placement_tile: TileData = tile_map.get_cell_tile_data(placements_tiles_layer, tile_map.local_to_map(get_global_mouse_position()) + cell)
		var ground_tile: TileData = tile_map.get_cell_tile_data(ground_tiles_layer, tile_map.local_to_map(get_global_mouse_position()) + cell)
		if !ground_tile:
			tile_map.set_cell(selector_validator_layer, tile_map.local_to_map(get_global_mouse_position()) + cell, invalid_placement.source_id, invalid_placement.image_cords)		
			all_valid = false
		elif (selected_building == mine && !placement_tile):
			tile_map.set_cell(selector_validator_layer, tile_map.local_to_map(get_global_mouse_position()) + cell, invalid_placement.source_id, invalid_placement.image_cords)
			all_valid = false
		elif placement_tile:
			if(selected_building == mine && placement_tile.get_custom_data("TerrainType") == "mountain"):
				tile_map.set_cell(selector_validator_layer, tile_map.local_to_map(get_global_mouse_position()) + cell, valid_placement.source_id, valid_placement.image_cords)
			else:
				tile_map.set_cell(selector_validator_layer, tile_map.local_to_map(get_global_mouse_position()) + cell, invalid_placement.source_id, invalid_placement.image_cords)
				all_valid = false
		elif invalid_placement_terrain.has(ground_tile.get_custom_data("TerrainType")):
			tile_map.set_cell(selector_validator_layer, tile_map.local_to_map(get_global_mouse_position()) + cell, invalid_placement.source_id, invalid_placement.image_cords)
			all_valid = false
		else:
			tile_map.set_cell(selector_validator_layer, tile_map.local_to_map(get_global_mouse_position()) + cell, valid_placement.source_id, valid_placement.image_cords)
	return all_valid
	
func is_max_villagers_exceeded():
	var to_placed_building = tile_map.get_cell_tile_data(selector_layer, tile_map.local_to_map(get_global_mouse_position())) 
	if (to_placed_building.get_custom_data("Villagers") + total_villagers <= max_villagers) || to_placed_building.get_custom_data("Villagers") == 0:
		return false
	else:
		placement_error("no villagers space")
		return true
		
func no_gold_to_pay():
	var to_placed_building = tile_map.get_cell_tile_data(selector_layer, tile_map.local_to_map(get_global_mouse_position())) 
	if total_gold - to_placed_building.get_custom_data("GoldCost") >= 0:
		return false
	else:
		placement_error("not enough gold")
		return true
	
func calculate_max_villagers():
	max_villagers = roundi(pow(total_charm, 2)/400)
	
func get_gold():
	SoundEffectPlayer.play_cashflow()
	total_gold += total_villagers 
		
func clear_current_building_selection():
	tile_map.clear_layer(selector_layer)
	tile_map.clear_layer(selector_validator_layer)
	is_building = false
	
func _on_small_house_pressed():
	SoundEffectPlayer.play_button_pressed()
	clear_current_building_selection()
	is_building = true
	selected_building = small_house

func _on_medium_house_pressed():
	SoundEffectPlayer.play_button_pressed()
	clear_current_building_selection()
	is_building = true
	selected_building = medium_house

func _on_big_house_pressed():
	SoundEffectPlayer.play_button_pressed()
	clear_current_building_selection()
	is_building = true
	selected_building = big_house

func _on_mine_pressed():
	SoundEffectPlayer.play_button_pressed()
	clear_current_building_selection()
	is_building = true
	selected_building = mine

func _on_church_pressed():
	SoundEffectPlayer.play_button_pressed()
	clear_current_building_selection()
	is_building = true
	selected_building = church

func _on_castle_pressed():
	SoundEffectPlayer.play_button_pressed()
	clear_current_building_selection()
	is_building = true
	selected_building = castle
