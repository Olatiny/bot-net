
class_name Board
extends Node2D


## Parent container of all possible path nodes
@onready var path_container: Node2D = $Paths


## List of OK paths
var valid_paths: Array[Path2D]

## List of Blacklisted Paths. Maintained in parallel with valid_paths to make a few things slightly easier
var invalid_paths: Array[Path2D]


## Virus scene reference
var VIRUS_SCENE := preload("res://src/entities/virus.tscn")


func _ready() -> void:
	var paths = path_container.get_children()
	
	for path in paths:
		valid_paths.push_back(path)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_spawn_virus") && OS.is_debug_build():
		var virus = VIRUS_SCENE.instantiate()
		add_virus_to_path(virus)


## Returns the path at the corresponding index
func get_virus_path(path_idx: int) -> Path2D:
	if path_idx < 0 || invalid_paths.has(path_container.get_child(path_idx)):
		return get_random_virus_path()
	
	return path_container.get_child(path_idx) as Path2D


## Returns a random path
func get_random_virus_path() -> Path2D:
	return valid_paths.pick_random() as Path2D


## adds a virus to a path
func add_virus_to_path(virus: Virus, path_idx := -1):
	get_virus_path(path_idx).add_child(virus)


## Invalidates the current path
## Signals game manager that game should end if game over
func invalidate_path(path: Path2D):
	_move_path_between_lists(path, valid_paths, invalid_paths)
	clear_path(path)
	
	## TODO: if all paths invalid, signal game over
	if valid_paths.size() <= 0 && GameManager.current_state != GameManager.GAME_STATE.GAME_OVER:
		GameManager.game_over()


## Checks if a path is valid
func check_path_valid(path: Path2D):
	return valid_paths.has(path)


## Checks if a path is valid
func check_path_valid_by_idx(path_idx: int):
	return valid_paths.has(path_container.get_child(path_idx))


## Validates a path
## NOTE: not intended to be possible, but supported regardless
func validate_path(path: Path2D):
	_move_path_between_lists(path, invalid_paths, valid_paths)


## Private helper to move a path between the valid and invalid list
func _move_path_between_lists(path: Path2D, list_from: Array[Path2D], list_to: Array[Path2D]):
	var idx = list_from.find(path)
	if idx >= 0 && !list_to.has(path):
		list_from.remove_at(idx)
		list_to.push_back(path)
	
	# sort according to order in container
	list_to.sort_custom(func (a: Path2D, b: Path2D): return a.get_index() < b.get_index())


## Resets the board state
func reset_board():
	for path in path_container.get_children():
		clear_path(path)
		_move_path_between_lists(path, invalid_paths, valid_paths)
	
	for folder in $Folders.get_children():
		folder = folder as GameFolder
		if folder.current_state == GameFolder.FOLDER_TYPE.ROOT:
			continue
		
		folder.neutralize_folder()


func clear_path(path: Path2D):
	for virus in path.get_children():
		virus.queue_free()


func clear_path_by_idx(path_idx: int):
	for virus in path_container.get_child(path_idx).get_children():
		virus.queue_free()
