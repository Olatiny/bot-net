class_name ButtonIntegration
extends VBoxContainer

@export var tower_scene: PackedScene 
@export var aoe_tower_scene: PackedScene
@export var wall_scene: PackedScene
@export var upgrade_cost_per_tower: int = 50 
var selected_towers: Array = []
@onready var upgrade_button = $%TowerPrompt

var ghost_tower: Node2D = null
var is_placing: bool = false


func _unhandled_input(event):
	if is_placing:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		check_for_tower_click(get_global_mouse_position())


func check_for_tower_click(mouse_pos):
	for tower in get_tree().get_nodes_in_group("towers"):
		if tower.global_position.distance_to(mouse_pos) < 32:
			var now_selected = tower.toggle_selection()
			if now_selected:
				selected_towers.append(tower)
			else:
				selected_towers.erase(tower)
			update_upgrade_ui()
			break


func update_upgrade_ui():
	var total_cost = selected_towers.size() * upgrade_cost_per_tower
	if !is_instance_valid(upgrade_button):
		return
	
	if selected_towers.size() > 0:
		upgrade_button.text = "Upgrade Towers ($" + str(total_cost) + ")"
		upgrade_button.disabled = false
	else:
		upgrade_button.text = "Select Towers\n to Upgrade"
		upgrade_button.disabled = true


func _on_upgrade_towers_button_pressed():
	for tower in selected_towers:
		tower.apply_upgrade()
	
	selected_towers.clear()
	update_upgrade_ui()


func _process(_delta):
	if is_placing and ghost_tower:
		# Follow the mouse
		var mouse_pos := get_viewport().get_mouse_position()
		var sub_viewport_transform := get_viewport().canvas_transform.origin
		#var main_viewport_transform := get_viewport().get_viewport().canvas_transform.origin
		ghost_tower.global_position = mouse_pos - sub_viewport_transform - Vector2(0, 100)# - get_viewport().get_camera_2d().position


func _input(event):
	if is_placing and event.is_action_pressed("left_click"):
		get_viewport().set_input_as_handled()
		finalize_placement()
	
	if is_placing and event.is_action_pressed("ui_cancel"):
		cancel_placement()


# --- BUTTON SIGNALS ---
func _on_upgrade_firewall_button_pressed():
	# This one line tells every node in the "firewalls" group 
	# to run its "upgrade_wall" function.
	get_tree().call_group("firewalls", "upgrade_wall")
	
	# Optional: Deduct currency here
	# gold -= upgrade_cost


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
	
	GameManager.game_board.add_child(ghost_tower)
	
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
	
	# Ensure it stays exactly where the ghost was
	#ghost_tower.global_position = get_global_mouse_position()
	
	ghost_tower.set_process(true)
	ghost_tower.set_physics_process(true)
	
	#ghost_tower.reparent(GameManager.game_board, false)
	#ghost_tower.position.y -= 310
	#ghost_tower.position.x -= 400
	
	AudioManager.sfx_play_place_sfx()
	
	# Enable detection
	for zone_name in ["DetectionRange", "DamageZone", "ThornArea"]:
		var zone = ghost_tower.get_node_or_null(zone_name)
		if zone:
			zone.monitoring = true
			
	ghost_tower = null


func toggle_tower_selection(tower):
	if tower in selected_towers:
		selected_towers.erase(tower)
	else:
		selected_towers.append(tower)
	update_upgrade_ui()


func cancel_placement():
	is_placing = false
	if ghost_tower:
		ghost_tower.queue_free() 
		ghost_tower = null


func _on_button_4_pressed() -> void:
	pass # Replace with function body.
