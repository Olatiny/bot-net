class_name GameFolder
extends Node2D


## Enum representation of folder types
enum FOLDER_TYPE {
	## Enemy folder, player cannot repair these & they act as spawn-points
	ROOT,
	## A folder that's doin well in this world.
	NEUTRAL, 
	## A folder that is infected with the virus, not defeated yet.
	INFECTED, 
	## A folder that has been defeated. 
	DEFEATED
}

## the current state of this folder
@export var current_state := FOLDER_TYPE.NEUTRAL

## maximum health of this folder
@export var max_virus_tolerance := 100.0

## current health of this folder
@export var tolerance := 0.0

## The path that should be disabled if this folder is defeated
@export var path_to_disable: Path2D = null


## List of virus data for contained viruses, needed to populate internal view
var virus_list: Array[Virus]

## State tracking open vs. close
var folder_open := false

## private field checking for mouse over
var _mouse_over := false


func _process(delta: float) -> void:
	if current_state == FOLDER_TYPE.ROOT:
		return
	
	if Input.is_action_just_pressed("attack") && _mouse_over:
		print("Folder clicked!")
		_try_open_folder()
	
	tolerance += virus_list.size() * delta
	$ProgressBar.value = tolerance
	
	if tolerance >= 100:
		current_state = FOLDER_TYPE.DEFEATED
	elif tolerance > 0:
		current_state = FOLDER_TYPE.INFECTED
	else:
		current_state = FOLDER_TYPE.NEUTRAL
	
	_try_change_path_validity()


## TODO: implement folder opening
func _try_open_folder():
	if is_instance_valid(GameManager.terminal):
		GameManager.terminal.push_new_message("Folder clicked!")
	
	## IF NOT DEFEATED, OPEN INTERFACE
	## IF DEFEATED, AND ENCRYPT PRIMED, OPEN RECAPTURE MINI-GAME
	## IF DEFEATED, AND NO ENCRYPT PRIMED, DO NOTHING
	
	# TODO: debug this later somethin up with this it only sorta works
	_on_mouse_exited() # necessary because apparently covering the folder doesn't trigger mouse exited?
	GlobalStates.folder_opened.emit(self)


## adds virus data to folder, adjusts 
func add_virus_to_folder(in_virus: Virus):
	virus_list.push_back(in_virus)
	tolerance += in_virus.max_health
	
	if !is_instance_valid(in_virus.get_parent()):
		add_child(in_virus)
	else:
		in_virus.call_deferred("reparent", self, true)
	
	if folder_open:
		GameManager.game_board.add_virus_to_simulation(in_virus)
		in_virus.set_enabled(true)
	else:
		in_virus.set_enabled(false)
	
	$ProgressBar.value = tolerance


## TODO: implement virus removal
func remove_virus_data():
	pass


## private detector of mouse
func _on_mouse_entered() -> void:
	_mouse_over = true


## private detector of mouse
func _on_mouse_exited() -> void:
	_mouse_over = false


func neutralize_folder():
	if current_state == FOLDER_TYPE.ROOT:
		return
	
	virus_list.clear()
	tolerance = 0.0
	current_state = FOLDER_TYPE.NEUTRAL


func _try_change_path_validity():
	if !is_instance_valid(path_to_disable):
		return
	
	var game_board: Board = GameManager.game_board
	
	if current_state == FOLDER_TYPE.DEFEATED && game_board.check_path_valid(path_to_disable):
		game_board.invalidate_path(path_to_disable)
	elif current_state != FOLDER_TYPE.DEFEATED && !game_board.check_path_valid(path_to_disable):
		game_board.validate_path(path_to_disable)
