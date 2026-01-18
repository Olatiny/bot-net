## class name: GameManager from AutoLoad
extends Node

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



func _process(delta: float) -> void:
	if current_state != GAME_STATE.ACTIVE:
		return
	
	elapsed_time += delta


## Called by game scene to initialize this singleton's references
func initialize_node_refs(in_virus_manager: VirusManager, in_terminal: Terminal, in_shop: Shop, in_game_board: Board) -> void:
	virus_manager = in_virus_manager
	terminal = in_terminal
	shop = in_shop
	game_board = in_game_board


## Called to start the game loop
func start_game() -> void:
	## TODO: Actually implement this lmao
	## TODO: idk maybe like a little ready ? loading bar or somth
	current_state = GAME_STATE.ACTIVE


## This function will delegate to the virus manager, passing in the current wave index
## to start the next wave, procedurally modifying the difficulty
func start_next_wave() -> void:
	pass


## Used to set pause state, TODO: pause menu interface
func set_pause(pause_state: bool):
	is_paused = pause_state


## Used to scramble the board, called by virus manager
func scramble_board():
	pass


## Called when a wave ends, signals HUD to update appropriately
func end_wave():
	pass
