extends Node2D

@export var damage: int = 25
var targets: Array = []

@onready var damage_zone = $DamageZone
@onready var attack_visual = $attack_visual
@onready var timer = $Timer


func _on_damage_zone_body_entered(body):
	if body.is_in_group("enemies"):
		targets.append(body)

func _on_damage_zone_body_exited(body):
	targets.erase(body)

func _on_timer_timeout():
	# Only attack if there are enemies in range
	print("AoE Timer Ticking... Enemies in range: ", targets.size()) # DEBUG 1
	if targets.size() > 0:
		attack()


func attack():
	print("AoE Pulsing!")
	show_pulse()
	
	# Duplicate list to safely iterate if an enemy dies mid-loop
	for enemy in targets.duplicate():
		if is_instance_valid(enemy) and enemy.has_method("take_damage"):
			enemy.take_damage(damage)

func show_pulse():
	attack_visual.visible = true
	var tween = get_tree().create_tween()
	
	# Start at 0.5 opacity yellow and fade to 0.0
	attack_visual.modulate.a = 0.5 
	tween.tween_property(attack_visual, "modulate:a", 0.0, 0.5) 
	
	# Cleanly hide after the tween finishes
	tween.finished.connect(func(): attack_visual.visible = false)
	
