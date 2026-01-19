class_name Board
extends Node2D


## Parent container of all possible path nodes
@onready var path_container: Node2D = $Paths


var VIRUS_SCENE := preload("res://src/entities/virus.tscn")


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_spawn_virus") && OS.is_debug_build():
		var virus = VIRUS_SCENE.instantiate()
		add_virus_to_path(virus)


## Returns the path at the corresponding index
func get_virus_path(path_idx: int) -> Path2D:
	if path_idx < 0:
		return get_random_virus_path()
	
	return path_container.get_child(path_idx) as Path2D


## Returns a random path
func get_random_virus_path() -> Path2D:
	return path_container.get_children().pick_random() as Path2D


## adds a virus to a path
func add_virus_to_path(virus: Virus, path_idx := -1):
	get_virus_path(path_idx).add_child(virus)
