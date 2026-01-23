## Representation of a virus in a folder. 
##
## These share data of the viruses that entered, but behave differently while inside a folder, 
## hence the different class.
class_name VirusFolderContainer
extends CharacterBody2D


## the virus component this transport pilots. 
@onready var contained_virus: Virus


## Gravity for this folder container
@export var gravity := 980


func add_virus(in_virus: Virus):
	contained_virus = in_virus
	in_virus.global_position = global_position
	
	if !is_instance_valid(in_virus.get_parent()):
		add_child(in_virus)
	else:
		in_virus.reparent(self, true)


func _on_virus_defeat():
	queue_free()


func move_virus(delta: float):
	velocity.y += gravity * delta
	velocity.y = minf(velocity.y, 2000)
	move_and_slide()
