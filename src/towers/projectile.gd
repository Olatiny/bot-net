class_name Projectile
extends Area2D

var target: Node2D = null
var speed: float = 600.0
var damage: int = 1 # Adjusted to match your Virus health (5)
var hit_threshold: float = 15.0 


func _physics_process(delta):
	if not is_instance_valid(target):
		queue_free()
		return

	var direction = (target.global_position - global_position).normalized()
	global_position += direction * speed * delta


	# Distance check for high-speed reliability
	if global_position.distance_to(target.global_position) < hit_threshold:
		_on_impact(target)


func _on_area_entered(area: Area2D):
	# If we hit the area we are tracking, or the parent of that area
	if area == target or area.get_parent() == target:
		_on_impact(area)


func _on_impact(hit_node):
	# 1. Try to find the 'process_attack' function on the hit node
	# 2. If not there, try the parent (the Virus script)
	var enemy_script = null
	
	if hit_node.has_method("process_attack"):
		enemy_script = hit_node
	elif hit_node.get_parent() and hit_node.get_parent().has_method("process_attack"):
		enemy_script = hit_node.get_parent()
		
	if enemy_script:
		(enemy_script as Virus).process_attack(damage)
	
	queue_free()
