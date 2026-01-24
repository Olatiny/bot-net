extends Node2D

@export var damage: int = 2
var upgrade_level: int = 1
var targets: Array = []
var is_selected: bool = false 
@onready var selection_visual = $SelectionVisual
@onready var damage_zone = $detection
@onready var attack_visual = $attack_visual
@onready var timer = $Timer

func _ready():
	if selection_visual:
		selection_visual.visible = false
	attack_visual.visible = false
	attack_visual.modulate.a = 0.0
func toggle_selection():
	is_selected =!is_selected
	if selection_visual:
		selection_visual.visible = is_selected
	modulate = Color(1.5, 1.5, 1.5) if is_selected else Color(0.912, 0.912, 0.452, 0.745)
	return is_selected


func apply_upgrade():
	upgrade_level += 1
	damage += 10 # Increase damage
	if timer:
		timer.wait_time = max(0.2, timer.wait_time * 0.8)
	is_selected = false
	if selection_visual:
		selection_visual.visible = false
	modulate = Color(1, 1, 1) # Reset highlight color


		
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
	
func _on_detection_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			toggle_selection()
			
			# Find the node in the 'manager' group instead of searching the tree
			var shop_manager = get_tree().get_first_node_in_group("manager")
			if shop_manager:
				shop_manager.toggle_tower_selection(self)
			else:
				print("Error: Manager group not found!")
