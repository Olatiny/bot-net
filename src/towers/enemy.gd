extends CharacterBody2D

var health: int = 50

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		die()

func die():
	queue_free() 
