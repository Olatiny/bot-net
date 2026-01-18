class_name MainGame
extends CanvasLayer

###################
###  NODE REFS  ###
###################

## The current virus manager
@onready var virus_manager := %VirusManager as VirusManager

## The current terminal
@onready var terminal := %Terminal as Terminal

## The current shop
@onready var shop := %Shop as Shop

## The current game board
@onready var game_board := %Board as Board



func _ready() -> void:
	## NOTE: probs gonna not just do this in ready, but for now just doin it in ready
	start_game()


func start_game() -> void:
	GameManager.initialize_node_refs(virus_manager, terminal, shop, game_board)
	GameManager.start_game()
