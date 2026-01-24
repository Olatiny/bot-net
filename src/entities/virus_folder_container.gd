## Representation of a virus in a folder. 
##
## These share data of the viruses that entered, but behave differently while inside a folder, 
## hence the different class.
class_name VirusFolderContainer
extends CharacterBody2D


## the virus component this transport pilots. 
@onready var contained_virus: Virus


### Gravity for this folder container
#@export var gravity := 980


func add_virus(in_virus: Virus):
	contained_virus = in_virus
	in_virus.global_position = global_position
	
	velocity = Vector2(randi_range(-200, 200), randi_range(-200, 200)) * remap(contained_virus.speed, 0, 0.3, 1, 3)
	
	if !is_instance_valid(in_virus.get_parent()):
		add_child(in_virus)
	else:
		#in_virus.animation_player.stop.call_deferred()
		in_virus.reparent.call_deferred(self)
		#in_virus.animation_player.clear_caches.call_deferred()


func _on_virus_defeat():
	queue_free()


func move_virus(delta: float):
	var coll_data: KinematicCollision2D = move_and_collide(velocity * delta)
	
	if !is_instance_valid(coll_data):
		return
	
	if coll_data.get_normal().x != 0:
		velocity.x *= -1
	
	if coll_data.get_normal().y != 0:
		velocity.y *= -1
