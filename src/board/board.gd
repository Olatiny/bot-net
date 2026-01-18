class_name Board
extends Node2D


## Parent container of all possible path nodes
@onready var path_container: Node2D = $Paths


## Returns the path at the corresponding index
func get_virus_path(path_idx: int) -> Path2D:
	return path_container.get_child(path_idx) as Path2D


## Returns a random path
func get_random_virus_path() -> Path2D:
	return path_container.get_children().pick_random() as Path2D


## adds a virus to a path
func add_virus_to_path(virus: Virus, path_idx: int):
	get_virus_path(path_idx).reparent(virus)
