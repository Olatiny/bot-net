extends Area2D

var target: CharacterBody2D = null
var speed: float = 600.0
var damage: int = 50
var hit_threshold: float = 10.0 

func _physics_process(delta):

	if not is_instance_valid(target):
		queue_free()
		return

	var direction = (target.global_position - global_position).normalized()

	global_position += direction * speed * delta

	look_at(target.global_position)


	if global_position.distance_to(target.global_position) < hit_threshold:
		_on_impact(target)

func _on_body_entered(body):

	if body == target:
		_on_impact(body)

func _on_impact(enemy):
	if enemy.has_method("take_damage"):
		enemy.take_damage(damage)
	queue_free() 
