class_name GameFolder
extends Sprite2D


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


## List of virus data for contained viruses, needed to populate internal view
var virus_data_list: Array[VirusData]

## private field checking for mouse over
var _mouse_over := false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("attack") && _mouse_over:
		print("Folder clicked!")
		_try_open_folder()


## TODO: implement folder opening
func _try_open_folder():
	GameManager.terminal.push_new_message("Folder clicked!")
	## IF NOT DEFEATED, OPEN INTERFACE
	## IF DEFEATED, AND ENCRYPT PRIMED, OPEN RECAPTURE MINI-GAME
	## IF DEFEATED, AND NO ENCRYPT PRIMED, DO NOTHING
	pass


## private detector of mouse
func _on_mouse_entered() -> void:
	_mouse_over = true


## private detector of mouse
func _on_mouse_exited() -> void:
	_mouse_over = false
