extends Node2D

@export var tower_scene: PackedScene 
@export var aoe_tower_scene: PackedScene
@export var wall_scene: PackedScene

var ghost_tower: Node2D = null
var is_placing: bool = false

func _process(_delta):
	if is_placing and ghost_tower:
		# Follow the mouse
		ghost_tower.global_position = get_global_mouse_position()

func _unhandled_input(event):
	if is_placing and event.is_action_pressed("left_click"):
		finalize_placement()

	if is_placing and event.is_action_pressed("ui_cancel"):
		cancel_placement()

# --- BUTTON SIGNALS ---

func _on_build_button_pressed():
	# For the standard projectile tower
	start_placement(tower_scene)

func _on_aoe_build_button_pressed():
	# For the AoE pulse tower
	start_placement(aoe_tower_scene)

# --- PLACEMENT LOGIC ---

func _on_build_wall_button_pressed():
	start_placement(wall_scene)



func start_placement(selected_tower: PackedScene):
	if is_placing: return # Prevent overlapping placements
	
	is_placing = true
	ghost_tower = selected_tower.instantiate()
	add_child(ghost_tower)
	
	# Make it look like a "ghost"
	ghost_tower.modulate.a = 0.5
	
	# Disable logic so it doesn't shoot/pulse while following the mouse
	ghost_tower.set_process(false)
	ghost_tower.set_physics_process(false)
	
	# Disable the Detection nodes so they don't find targets yet
	# This checks for both "DetectionRange" and "DamageZone"
	for node_name in ["DetectionRange", "DamageZone"]:
		var detection = ghost_tower.get_node_or_null(node_name)
		if detection:
			detection.monitoring = false


func finalize_placement():
	is_placing = false
	ghost_tower.modulate.a = 1.0
	ghost_tower.set_physics_process(true)
	
	# Enable detection for Towers AND Walls
	for zone_name in ["DetectionRange", "DamageZone", "ThornArea"]:
		var zone = ghost_tower.get_node_or_null(zone_name)
		if zone:
			zone.monitoring = true
			
	ghost_tower = null

func cancel_placement():
	is_placing = false
	if ghost_tower:
		ghost_tower.queue_free() 
		ghost_tower = null
