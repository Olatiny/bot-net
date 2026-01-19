extends StaticBody2D

@export var max_health: int = 200
@export var thorn_damage: int = 50 # Damage dealt to enemy on contact
var current_health: int

func _ready():
	current_health = max_health

func take_damage(amount: int):
	current_health -= amount
	print("Wall Health: ", current_health)
	if current_health <= 0:
		die()

func _on_thorn_area_body_entered(body):
	# If an enemy touches the wall
	if body.is_in_group("enemies"):
		# 1. Damage the enemy
		if body.has_method("take_damage"):
			body.take_damage(thorn_damage)
		
		# 2. Damage the wall (the wall takes damage for 'blocking')
		take_damage(50) 

func die():
	queue_free()
