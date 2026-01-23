## A base class for the viruses. 
## Extends path follow 2D so they can automatically follow a path using 
## `progress_ratio`
class_name VirusPathContainer
extends PathFollow2D


## the virus component this transport pilots. 
var contained_virus: Virus


func add_virus(in_virus: Virus):
	contained_virus = in_virus
	add_child(in_virus)


func move_virus(delta: float):
	if get_parent() is Path2D:
		progress_ratio += delta * contained_virus.speed


func _on_virus_defeat():
	queue_free()
