extends Node2D

@export var projectile_scene: PackedScene
@export var damage: int = 10
var upgrade_level: int = 1
var is_selected: bool = false

var targets: Array = []
var current_target: Node2D = null

@onready var selection_visual = $SelectionVisual
@onready var timer = $Timer

func _ready():
	# Ensure visual is hidden at start
	if selection_visual:
		selection_visual.visible = false
	# Ensure the tower is in the 'towers' group so the Shop can find it
	add_to_group("towers")

# --- SELECTION LOGIC ---

func toggle_selection():
	is_selected = !is_selected
	if selection_visual:
		selection_visual.visible = is_selected
	
	# Visual feedback: Tints the tower slightly brighter when selected
	modulate = Color(1.5, 1.5, 1.5) if is_selected else Color(1, 1, 1)
	return is_selected

func _on_detection_range_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			toggle_selection()
			
			# Tell the shop (VBoxContainer) we were clicked
			# Using a group is safer than searching the tree
			var shop = get_tree().get_first_node_in_group("shop")
			if shop:
				shop.toggle_tower_selection(self)

# --- UPGRADE LOGIC ---

func apply_upgrade():
	upgrade_level += 1
	damage += 5  # Increase projectile damage
	
	if timer:
		# Shoot 15% faster with each upgrade
		timer.wait_time = max(0.15, timer.wait_time * 0.85)
	
	# Reset selection state after upgrading
	is_selected = false
	if selection_visual:
		selection_visual.visible = false
	modulate = Color(1, 1, 1)

# --- COMBAT LOGIC ---

func _on_detection_range_area_entered(area: Area2D):
	if area.is_in_group("enemies") or (area.get_parent() and area.get_parent().is_in_group("enemies")):
		if not targets.has(area):
			targets.append(area)

func _on_detection_range_area_exited(area: Area2D):
	targets.erase(area)

func _physics_process(_delta):
	current_target = get_closest_target()
	if is_instance_valid(current_target):
		look_at(current_target.global_position)

func get_closest_target():
	var closest = null
	var min_dist = INF
	var valid_targets = []
	
	for t in targets:
		if is_instance_valid(t):
			valid_targets.append(t)
			var dist = global_position.distance_to(t.global_position)
			if dist < min_dist:
				min_dist = dist
				closest = t
	
	targets = valid_targets
	return closest

func _on_timer_timeout():
	if is_instance_valid(current_target):
		shoot()

func shoot():
	if not projectile_scene: return
	var p = projectile_scene.instantiate()
	
	# Use GameManager to place the projectile on the board
	GameManager.game_board.add_child(p) 

	p.global_position = self.global_position 
	p.target = current_target
	# If your projectile has a damage variable, set it here:
	if "damage" in p:
		p.damage = damage
