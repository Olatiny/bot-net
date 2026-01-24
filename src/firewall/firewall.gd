extends StaticBody2D

@export var max_health: int = 20
@export var thorn_damage: int = 10 
var current_health: int
var upgrade_level: int = 1
@export var upgraded_sprite: Texture2D


func _ready():
	add_to_group("firewalls")
	current_health = max_health
	
func upgrade_wall():
	upgrade_level +=1
	max_health += 20
	current_health = max_health
	if upgraded_sprite:
		$Sprite2D.texture = upgraded_sprite
	print("Firewall upgraded to Level ", upgrade_level, ". Max Health: ", max_health)
func _on_thorn_area_area_entered(area: Area2D):

	# Try to find where the Virus script (and process_attack) lives
	var virus_node = null
	
	if area.has_method("process_attack"):
		virus_node = area

	elif area.get_parent() and area.get_parent().has_method("process_attack"):
		virus_node = area.get_parent()

	else:

		return

	# Check the group
	if virus_node.is_in_group("enemies") or area.is_in_group("enemies"):

		# Apply damage
		var health_before = virus_node.health
		virus_node.process_attack(thorn_damage)
		# Damage the wall
		take_damage(2) 



func take_damage(amount: int):
	current_health -= amount
	if current_health <= 0:
		queue_free()
