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


###################
### GAME STATES ###
###################

## Enum for different game states control flow
enum GAME_STATE {READY, ACTIVE, SHOP, GAME_OVER}

## current game state
var current_state: GAME_STATE = GAME_STATE.READY

## current player currency
var player_ram := 0

## current player ram income every second
var ram_income := 1

## Current player click attack damage
var player_attack_damage := 1

## time elapsed of playthrough, resets each defeat (seconds)
var elapsed_time := 0.0

## time limit for shop phase between waves (seconds)
var between_wave_shop_time := 30

## current wave index
var current_wave_idx := 0

## paused state
var is_paused := false


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


## Timer for length of wave
@onready var wave_timer := $WaveTimer as Timer

## Cooldown timer between waves
@onready var wave_cooldown := $WaveCooldown as Timer



func _process(delta: float) -> void:
	if current_state != GAME_STATE.ACTIVE:
		return
	
	elapsed_time += delta


## Called by game scene to initialize this singleton's references
func initialize_node_refs(in_virus_manager: VirusManager, in_terminal: Terminal, in_shop: Shop, in_game_board: Board, in_popup_container: Control) -> void:
	virus_manager = in_virus_manager
	terminal = in_terminal
	shop = in_shop
	game_board = in_game_board
	popup_container = in_popup_container


## Called to start the game loop
func start_game() -> void:
	## TODO: Actually implement this lmao
	## TODO: idk maybe like a little ready ? loading bar or somth
	current_state = GAME_STATE.ACTIVE
	
	start_next_wave()


## This function will delegate to the virus manager, passing in the current wave index
## to start the next wave, procedurally modifying the difficulty
func start_next_wave() -> void:
	current_wave_idx += 1
	virus_manager.start_wave(current_wave_idx)
	
	terminal.push_new_message("[color=cb2a5e]VIRUS WAVE: [shake rate=20.0 level=25 connected=1]" + str(current_wave_idx) + "[/shake][/color]", system_name)
	
	if wave_timer.is_stopped():
		wave_timer.start()


## Used to set pause state, TODO: pause menu interface
func set_pause(pause_state: bool):
	is_paused = pause_state


## Spawns a popup at a random location on the board, or one submitted
func spawn_popup(coords := Vector2(-1, -1)):
	GameManager.terminal.push_new_message("Uh Oh! Get blocked loser :p", virus_name)
	
	var popup := POPUP_SCENE.instantiate() as GamePopup
	
	if coords.x < 0 || coords.y < 0:
		var size := popup_container.size - (2 * popup.size)
		coords = Vector2(randf_range(0, size.x), randf_range(0, size.y)) + popup.size
	
	popup.global_position = coords
	popup_container.add_child(popup)


## Used to scramble the board, called by virus manager
func scramble_board():
	pass


## Called when a wave ends, signals HUD to update appropriately
func end_wave():
	if current_state == GAME_STATE.GAME_OVER:
		GameManager.terminal.push_new_message("GET DUNKED ON", virus_name)
		return
	
	# NOTE: spacing was an accident but looks kinda cool actually?
	GameManager.terminal.push_new_message("[color=white]Wave " + str(current_wave_idx) + " over.[/color]
		[color=cb2a5e][shake rate=20.0 level=25 connected=1]" + str(ceili(wave_cooldown.wait_time)) + " seconds remain[/shake][/color]")
	
	virus_manager.end_wave()
	
	if wave_cooldown.is_stopped():
		wave_cooldown.start()
