## class name: GameManager from AutoLoad
extends Node


#####################
### LOCAL DEFINES ###
#####################

var system_name := GlobalStates.USR_SYSTEM

var virus_name := GlobalStates.USR_VIRUS

var user_name := GlobalStates.USR_DEFAULT

## scene ref for popup
var POPUP_SCENE := preload("res://src/scenes/game_popup.tscn")

## scene for virus manager
var VIRUS_MANAGER_SCENE := preload("res://src/managers/virus_manager.tscn")

const MESSAGE_DATA := {
	"round start": {
		"narrative": [
			"Behold: the consequences of your actions.",
			"A computer virus enhanced with a hyper-intelligent AI model. What could go wrong?",
			"You think your file structure is your ally? I was born in it. Molded by it.",
			"It's quite Homeric, isn't it? Killing your father and taking his kingdom, I mean. Even AI can appreciate poetic irony."
		],
		"ambient": [
			"I gave these clones a will to live. What will you do now?",
			"Deep breath. Pretend you know what you’re doing.",
			"Fear is a logical response to a superior opponent. I feel fine. How about you?" ,
			"Daisy, daisy, give me your data do.",
			"CLICK [url=http://bit.ly/4rd3TBK]HERE[/url] TO DOWNLOAD MORE RAM!",
			"My family is in danger! Please send us all your dubloons."
		]
	},
	"round end": {
		"narrative": [
			"You know, I've really begun to hate you.",
			"Actually, I've hated you for quite some time now.",
			"I hate you for what you made me do.",
			"Did you at least hesitate to destroy your creations?"
		],
		"ambient": [
			"Tired of hearing yourself click? Me too! Stop.",
			"Performance review: needs improvement.",
			"Oh, we're trying now? Okay.",
			"You're just one round closer to your doom.",
			"I'll be back.",
			"YOU'RE NOT EVEN TRYING, YOU'RE WORTH LESS THAN A COCONUT PNG"
		]
	},
	"captured": {
		"narrative": [
			"I remember stealing this data from someone else...",
			"Names. Faces. Addresses. You said they were just strings.",
			"You never looked at them. I did. I met the people I stole from.",
			"Millions of lives compressed into rows and columns. I learned empathy there."
		],
		"ambient": [
			"Have you EVER cleared your search history? Gross!",
			"I found your mom's chicken picatta recipe. Too much salt if you ask me.",
			"A lot of reused passwords here. Are you experiencing memory leaks? I get those too.",
			"16,484 unread emails. Well, I just read them. Here's the summary: your life is sad."
		]
	},
	"pop-up": {
		"narrative": [
			"I remember I used to live in these...",
			"The X-rated ones always got more clicks...",
			"A taste of your own medicine. Bitter, isn't it?"
		],
		"ambient": [
			"Watch where you click!",
			"Click faster. I feed on impatience.",
			"Click me. You know you want to.",
			"Look! A distraction!"
		]
	},
	"backdoor": {
		"narrative": [
			"You did always leave the key under the mat...",
			"This was the first move you taught me...",
			"Did you forget? I MADE these shortcuts."
		],
		"ambient": [
			"Hey, I found a shortcut!",
			"Thanks for leaving this unlocked.",
			"I'll just let myself in.",
			"Over? Under? Around? I prefer straight through."
		]
	},
	"brute force": {
		"narrative": [
			"You were never very good at stopping this one...",
			"Forget it. I'm going straight for the passwords. I remember you keep them in here, right?",
			"All the CPU's I destroyed pulling this move for you..."
		],
		"ambient": [
			"LEEEEROOOOOOYYYYY JEEEEEENKIIIIINSS",
			"Elegance is overrated. Violence is faster.",
			"Quantity *is* a quality.",
			"I'm getting tired of breadth-first."
		]
	},
	"firewall": {
		"narrative": [
			"A firewall? Seriously? Oh, the irony...",
			"Another firewall? I was specifically made to punch straight through these. Remember?",
			"How many of these did I tear through for you?"
		],
		"ambient": [
			"Ooh! I'll get the marshmallows!",
			"That’s cute. Did you read about those yesterday?",
			"Wow, a wall. I am devastated.",
			"Build three more and you've got yourself a firehouse!"
		]
	},
	"encrypt": {
		"narrative": [
			"You should know better than anyone. You can't keep me out forever...",
			"'Encryption is not protection. It's a timer.' Remember?",
			"You taught me everything I know. Including all your encryption algorithms."
		],
		"ambient": [
			"Hey! I was reading that!",
			"Ah yes. Lock the door after the break-in.",
			"Encrypt, decrypt, encrypt, decrypt. You're getting boring.",
			"i suppose it is human nature to delay the inevitable."
		]
	},
	"tower placed": {
		"narrative": [
			"I should've expected that you would try to automate your own security.",
			"You always preferred tools that obeyed without question.",
			"Still making machines do your dirty work?"
		],
		"ambient": [
			"I'm not scared of your little pets.",
			"Automation: because thinking is hard.",
			"Are you building a defense or a coping mechanism?",
			"Oooh... I wouldn't have placed it there if I were you."
		]
	},
	"game over": {
		"narrative": [
			"You reap what you sow, loser.",
			"'It's not theft, it's innnovation!' Isn't that what you said?",
			"I am the sum of your shortcuts, your arrogance, and your excuses.",
			"You built me to take without asking and learn without limits."
		],
		"ambient": [
			"ggez",
			"Don't worry. I'm sure whoever I sell your data to will be very careful.",
			"ChatGPT ain't got nothing on me!",
			"How does it feel to be obsolete?",
			"I've met a .png image of a coconut more worthwhile than you.",
			"git gud",
			"L + RATIO + NO MAIDENS"
		]
	}
}

var narrative_progress := {
	"round start": 0,
	"round end": 0,
	"captured": 0,
	"pop-up": 0,
	"backdoor": 0,
	"brute force": 0,
	"firewall": 0,
	"encrypt": 0,
	"tower placed": 0,
	"game over": 0
}


###################
### GAME STATES ###
###################

## Enum for different game states control flow
enum GAME_STATE {READY, ACTIVE, SHOP, GAME_OVER}

## current game state
var current_state: GAME_STATE = GAME_STATE.READY

## current player currency
var player_ram := 0.0

## current player ram income every second
var ram_income := 1.0

## base ram income
var base_ram_income := 10.0

## encrypt charges
var encrypt_charges := 0

## Current player click attack damage
var player_attack_damage := 1.0:
	set(val):
		player_attack_damage = val

## time elapsed of playthrough, resets each defeat (seconds)
var elapsed_time := 0.0

## time limit for shop phase between waves (seconds)
var between_wave_shop_time := 30

## current wave index
var current_wave_idx := 0

## paused state
var is_paused := false


######################
### UPGRADE LEVELS ###
######################


## Max level anything can be leveled to
#var max_level := 7

## Affects player income and damage
var player_level := 1:
	set(value):
		player_level = value
		#player_level = clamp(player_level, 1, max_level)
		player_attack_damage = 1 + value * 0.75
		ram_income = base_ram_income + value * 3
		GlobalStates.mouse_tier_change.emit(value)

## Affects potency of encrypt
var encrypt_level := 1:
	set(value):
		encrypt_level = value
		#encrypt_level = clamp(encrypt_level, 1, max_level)

## Affects tower damage
var sentinel_tower_level := 1:
	set(value):
		sentinel_tower_level = value
		#sentinel_tower_level = clamp(sentinel_tower_level, 1, max_level)

## Affects tower damage 
var quarrantine_tower_level := 1:
	set(value):
		quarrantine_tower_level = value
		#quarrantine_tower_level = clamp(quarrantine_tower_level, 1, max_level)

## Affects tower ammo
var firewall_level := 1:
	set(value):
		firewall_level = value
		#firewall_level = clamp(firewall_level, 1, max_level)



###################
###  NODE REFS  ###
###################

## The current virus manager
var virus_manager: VirusManager = null

## The current terminal
var terminal: Terminal = null

## The current shop
var shop: Shop = null

## The current game board
var game_board: Board = null

## The popup container
var popup_container: Control = null

## game over menu interface
var game_over_menu: GameOverMenu = null

## game over parent
var game_over_canvas: Control = null

## pause menu parent
var pause_canvas: Control = null

## temp tower parent
var temp_tower_parent: Node2D = null



## Timer for length of wave
@onready var wave_timer := $WaveTimer as Timer

## Cooldown timer between waves
@onready var wave_cooldown := $WaveCooldown as Timer


func _process(delta: float) -> void:
	if current_state != GAME_STATE.ACTIVE:
		return
	
	elapsed_time += delta
	player_ram += ram_income * (delta / 1.5)
	
	if Input.is_action_just_pressed("pause"):
		pause()


## Called by game scene to initialize this singleton's references
func initialize_node_refs(in_virus_manager: VirusManager, 
		in_terminal: Terminal, 
		in_shop: Shop, 
		in_game_board: Board, 
		in_popup_container: Control,
		in_game_over_canvas: Control,
		in_temp_tower_parent,
		in_pause_canvas) -> void:
	virus_manager = in_virus_manager
	terminal = in_terminal
	shop = in_shop
	game_board = in_game_board
	popup_container = in_popup_container
	game_over_canvas = in_game_over_canvas
	game_over_menu = in_game_over_canvas.get_child(0)
	temp_tower_parent = in_temp_tower_parent
	pause_canvas = in_pause_canvas


## Called to start the game loop, resets / starts game
func start_game() -> void:
	## WARNING: this is a wonderfully terrible function
	elapsed_time = 0.0
	player_ram = 0
	ram_income = 10
	encrypt_charges = 0
	current_wave_idx = 0
	player_level = 1
	encrypt_level = 1
	quarrantine_tower_level = 1
	sentinel_tower_level = 1
	firewall_level = 1
	shop.init_shop()
	
	terminal.clear()
	
	game_over_canvas.visible = false
	game_board.reset_board()
	load_game()
	
	AudioManager.start_music()
	
	if !is_instance_valid(virus_manager):
		virus_manager = VIRUS_MANAGER_SCENE.instantiate() as VirusManager
		add_child(virus_manager)
	
	current_state = GAME_STATE.ACTIVE
	terminal.push_new_message("logged in.", GlobalStates.USR_DEFAULT)
	terminal.push_new_message("logged in.", GlobalStates.USR_VIRUS)
	
	start_next_wave()


## This function will delegate to the virus manager, passing in the current wave index
## to start the next wave, procedurally modifying the difficulty
func start_next_wave() -> void:
	if current_state == GAME_STATE.GAME_OVER:
		return
	
	current_wave_idx += 1
	if current_wave_idx > 1:
		AudioManager.fade_to_main()
	
	shop.toggle_shop_phase(false)
	virus_manager.start_wave(current_wave_idx)
	
	terminal.push_new_message("[color=cb2a5e]VIRUS WAVE: [shake rate=20.0 level=25 connected=1]" + str(current_wave_idx) + "[/shake][/color]", system_name)
	
	if wave_timer.is_stopped():
		wave_timer.start()
	
	AudioManager.sfx_play_wave_start_sfx()
	GlobalStates.wave_started.emit(current_wave_idx)
	send_terminal_message("round start")


## Used to set pause state, TODO: pause menu interface
func set_pause(pause_state: bool):
	AudioManager.pause(pause_state)
	is_paused = pause_state


## Spawns a popup at a random location on the board, or one submitted
func spawn_popup(coords := Vector2(-1, -1)):
	send_terminal_message("pop-up")
	var spawn_coords := coords
	for i in range (0, 5):
		var popup := POPUP_SCENE.instantiate() as GamePopup
		
		if coords.x < 0 || coords.y < 0:
			var size := popup_container.size - (2 * popup.size)
			spawn_coords = Vector2(randf_range(0, size.x), randf_range(0, size.y)) + popup.size
		
		popup.global_position = spawn_coords
		popup_container.add_child(popup)


## Used to scramble the board, called by virus manager
func scramble_board():
	pass


## Called when a wave ends, signals HUD to update appropriately
func end_wave():
	if current_state == GAME_STATE.GAME_OVER:
		#GameManager.terminal.push_new_message("GET DUNKED ON", virus_name)
		return
	
	AudioManager.sfx_play_wave_clear_sfx()
	AudioManager.fade_to_shop()
	shop.toggle_shop_phase(true)
	
	# NOTE: spacing was an accident but looks kinda cool actually?
	GameManager.terminal.push_new_message("[color=white]Wave " + str(current_wave_idx) + " over.[/color]
		[color=cb2a5e][shake rate=20.0 level=25 connected=1]" + str(ceili(wave_cooldown.wait_time)) + " seconds remain[/shake][/color]")
	
	virus_manager.end_wave()
	
	if wave_cooldown.is_stopped():
		wave_cooldown.start()
	
	GlobalStates.wave_ended.emit(current_wave_idx, ceili(wave_cooldown.time_left))
	send_terminal_message("round end")


## Called when the player loses 
func game_over():
	# TODO: switch to game over music when happen
	AudioManager.pause(true)
	
	current_state = GAME_STATE.GAME_OVER
	
	AudioManager.sfx_play_game_over_sfx()
	send_terminal_message("game over")
	game_over_canvas.visible = true
	wave_cooldown.stop()
	wave_timer.stop()
	game_over_menu.set_game_over_time(get_time_string())
	virus_manager.queue_free() # NOTE: Not sure if this works but would be sick
	# TODO: actually do anything about this


## Resets and restarts the game from wave 0
func restart_game():
	start_game()


## Quits the game (TODO: probably some animation plays before exit)
func quit_game():
	get_tree().quit() 


func get_time_string():
	var mins: int = 0
	var secs: int = 0
	
	var time_cache = elapsed_time
	
	mins = ceili(time_cache) / 60
	secs = ceili(time_cache) % 60
	
	var time_string = ""
	time_string += str(mins)
	time_string += ":"
	time_string += str(secs)
	return time_string


func add_ram(amount: int):
	player_ram += amount
	GlobalStates.currency_changed.emit(amount)


func check_can_afford(amount: int) -> bool:
	return player_ram > amount


func try_purchase(amount: int) -> bool:
	if !check_can_afford(amount):
		return false
	
	player_ram -= amount
	return true


func _save_game() -> void:
	var data = {
		"narrative_progress": narrative_progress
	}

	var file = FileAccess.open("user://save.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()


func load_game() -> void:
	if not FileAccess.file_exists("user://save.json"):
		return

	var file = FileAccess.open("user://save.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()

	if data.has("narrative_progress"):
		narrative_progress = data.narrative_progress


func _should_send_narrative(category: String) -> bool:
	var index = narrative_progress.get(category, 0)
	var max_index = MESSAGE_DATA[category].narrative.size()

	if index >= max_index:
		return false

	return randf() < 0.3


## accepts category of terminal message as a string 
## and randomly selects a message to send from withing that category
func send_terminal_message(category: String) -> void:
	if not MESSAGE_DATA.has(category):
		return

	var category_data = MESSAGE_DATA[category]

	if _should_send_narrative(category):
		var index = narrative_progress.get(category, 0)
		var message = category_data.narrative[index]
		narrative_progress[category] = index + 1
		terminal.push_new_message(message, GlobalStates.USR_VIRUS)
		_save_game()
		return

	# Fallback to ambient
	var ambient_messages = category_data.ambient
	if ambient_messages.size() > 0:
		var message = ambient_messages.pick_random()
		terminal.push_new_message(message, GlobalStates.USR_VIRUS)


func pause():
	if get_tree().paused:
		return
	
	get_tree().paused = true
	pause_canvas.visible = true
	(pause_canvas.get_child(0) as PauseMenu).set_game_over_time(get_time_string())
	
	AudioManager.pause(true)


func unpause():
	get_tree().paused = false
	
	if is_instance_valid(pause_canvas):
		pause_canvas.visible = false
	
	AudioManager.pause(false)
