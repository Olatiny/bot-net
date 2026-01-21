extends Node2D

@export var damage: int = 2
var targets: Array = []

@onready var damage_zone = $DamageZone
@onready var attack_visual = $attack_visual
@onready var timer = $Timer

func _ready():

	attack_visual.visible = false
	attack_visual.modulate.a = 0.0

# FIX 1: Change to _on_damage_zone_area_entered (for Area2D enemies)
func _on_damage_zone_area_entered(area: Area2D):
	# Check the area or its parent for the "enemies" group
	if area.is_in_group("enemies") or (area.get_parent() and area.get_parent().is_in_group("enemies")):
		if not targets.has(area):
			print("Enemy entered AoE range: ", area.name)
			targets.append(area)

# FIX 2: Change to _on_damage_zone_area_exited
func _on_damage_zone_area_exited(area: Area2D):
	if targets.has(area):
		print("Enemy left AoE range")
		targets.erase(area)

func _on_timer_timeout():
	# DEBUG: This will show in the bottom 'Output' console
	if targets.size() > 0:
		print("AoE Timer Ticking... Enemies in range: ", targets.size())
		attack()

func attack():
	show_pulse()
	
	# Duplicate list to safely iterate
	for target_node in targets.duplicate():
		if is_instance_valid(target_node):
			# FIX 3: Look for 'process_attack' instead of 'take_damage'
			var enemy_script = null
			
			if target_node.has_method("process_attack"):
				enemy_script = target_node
			elif target_node.get_parent() and target_node.get_parent().has_method("process_attack"):
				enemy_script = target_node.get_parent()
				
			if enemy_script:
				enemy_script.process_attack(damage)
		else:
			# Clean up the list if the enemy was destroyed elsewhere
			targets.erase(target_node)

func show_pulse():
	attack_visual.visible = true
	var tween = get_tree().create_tween()
	
	attack_visual.modulate.a = 0.5 
	tween.tween_property(attack_visual, "modulate:a", 0.0, 0.5) 

	tween.finished.connect(func(): attack_visual.visible = false)
	
