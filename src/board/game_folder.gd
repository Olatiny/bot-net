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


## List of virus data for contained viruses, needed to populate internal view
var virus_data_list: Array[VirusData]

## private field checking for mouse over
var _mouse_over := false


func _process(delta: float) -> void:
	if current_state == FOLDER_TYPE.ROOT:
		return
	
	if Input.is_action_just_pressed("attack") && _mouse_over:
		print("Folder clicked!")
		_try_open_folder()
	
	tolerance += virus_data_list.size() * delta
	$ProgressBar.value = tolerance
	
	if tolerance >= 100:
		current_state = FOLDER_TYPE.DEFEATED
	elif tolerance > 0:
		current_state = FOLDER_TYPE.INFECTED
	else:
		current_state = FOLDER_TYPE.NEUTRAL


## TODO: implement folder opening
func _try_open_folder():
	if is_instance_valid(GameManager.terminal):
		GameManager.terminal.push_new_message("Folder clicked!")
	
	## IF NOT DEFEATED, OPEN INTERFACE
	## IF DEFEATED, AND ENCRYPT PRIMED, OPEN RECAPTURE MINI-GAME
	## IF DEFEATED, AND NO ENCRYPT PRIMED, DO NOTHING


## adds virus data to folder, adjusts 
func add_virus_data(in_virus_data: VirusData):
	virus_data_list.push_back(in_virus_data)
	tolerance += in_virus_data.curr_health
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
