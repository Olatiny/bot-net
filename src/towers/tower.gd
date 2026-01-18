extends Node2D



@export var projectile_scene: PackedScene
var targets: Array = []
var current_target: CharacterBody2D = null
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_detection_range_body_entered(body):
	if body.is_in_group("enemies"):
		targets.append(body)

func _on_detection_range_body_exited(body):
	targets.erase(body)

func _physics_process(_delta):
	current_target = get_closest_target()
	if is_instance_valid(current_target):
		look_at(current_target.global_position)

func get_closest_target():
	var closest = null
	var min_dist = INF
	for t in targets:
		if is_instance_valid(t):
			var dist = global_position.distance_to(t.global_position)
			if dist < min_dist:
				min_dist = dist
				closest = t
	return closest

func _on_timer_timeout():
	if is_instance_valid(current_target):
		shoot()

func shoot():
	var p = projectile_scene.instantiate()
	get_tree().current_scene.add_child(p) 

	p.global_position = self.global_position 
	p.target = current_target
