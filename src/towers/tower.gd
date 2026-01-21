extends Node2D

@export var projectile_scene: PackedScene
var targets: Array = []
var current_target: Node2D = null # Using Node2D to be flexible

func _on_detection_range_area_entered(area: Area2D):
	# We check if the area or its parent (the Virus script) is in the group
	print("Something entered range: ", area.name)
	if area.is_in_group("enemies") or (area.get_parent() and area.get_parent().is_in_group("enemies")):
		if not targets.has(area):
			targets.append(area)

func _on_detection_range_area_exited(area: Area2D):
	targets.erase(area)

func _physics_process(_delta):
	current_target = get_closest_target()
	if is_instance_valid(current_target):
		look_at(current_target.global_position)

func get_closest_target():
	var closest = null
	var min_dist = INF
	var valid_targets = []
	
	for t in targets:
		if is_instance_valid(t):
			valid_targets.append(t)
			var dist = global_position.distance_to(t.global_position)
			if dist < min_dist:
				min_dist = dist
				closest = t
	
	targets = valid_targets
	return closest

func _on_timer_timeout():
	if is_instance_valid(current_target):
		shoot()

func shoot():
	if not projectile_scene: return
	var p = projectile_scene.instantiate()
	# Adding to current_scene so it doesn't rotate with the tower
	GameManager.game_board.add_child(p) 

	p.global_position = self.global_position 
	p.target = current_target
