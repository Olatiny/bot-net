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
	if !get_parent() is GamePath:
		return
	
	var parent := get_parent() as GamePath
	var move_amout: float = delta * contained_virus.speed
	
	if parent._backdoor_active && progress_ratio + move_amout > parent.backdoor_start && progress_ratio < parent.backdoor_start:
		progress_ratio = parent.backdoor_end
	else:
		progress_ratio += delta * contained_virus.speed


func _on_virus_defeat():
	queue_free()
