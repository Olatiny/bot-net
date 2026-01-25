class_name Firewall
extends StaticBody2D

@export var max_health: int = 20
@export var thorn_damage: int = 10 
@export var max_scale := 1.5
@export var min_scale := 1.0
var current_health: int
var upgrade_level: int = 1
@export var upgraded_sprite: Texture2D


func _ready():
	add_to_group("firewalls")
	current_health = max_health
	
	$HealthBar.value = current_health
	$HealthBar.max_value = max_health


func upgrade_wall():
	upgrade_level +=1
	max_health += 20
	current_health = max_health
	
	$HealthBar.value = current_health
	$HealthBar.max_value = max_health
	
	(material as ShaderMaterial).set_shader_parameter("dest_color_1", GlobalStates.get_tier_color(upgrade_level))
	
	#if upgraded_sprite:
		#$Sprite2D.texture = upgraded_sprite
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
		$AttackPlayer.play("attack")
		
		# Apply damage
		var health_cache = virus_node.health
		var health_diff = current_health - health_cache
		
		if health_diff > 0:
			virus_node.process_attack(health_cache)
		else:
			virus_node.process_attack(abs(health_diff))
		
		# Damage the wall
		take_damage(health_cache) 


func take_damage(amount: int):
	current_health -= amount
	
	$HealthBar.value = current_health
	$HealthBar.max_value = max_health
	
	#var scalar = lerp(min_scale, max_scale, float(current_health) / float(max_health))
	#scale = Vector2(scalar, scalar)
	
	if current_health <= 0:
		$KillThySelf.play("you_should")
