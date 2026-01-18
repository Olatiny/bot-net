extends Node2D

@export var tower_scene: PackedScene 

var ghost_tower: Node2D = null
var is_placing: bool = false

func _process(_delta):
	if is_placing and ghost_tower:
		ghost_tower.global_position = get_global_mouse_position()

func _unhandled_input(event):
	if is_placing and event.is_action_pressed("left_click"):
		finalize_placement()

	if is_placing and event.is_action_pressed("ui_cancel"):
		cancel_placement()

func _on_build_button_pressed():
	if not is_placing:
		start_placement()

func start_placement():
	is_placing = true
	ghost_tower = tower_scene.instantiate()
	add_child(ghost_tower)
	
	ghost_tower.modulate.a = 0.5
	ghost_tower.set_process(false)
	ghost_tower.set_physics_process(false)
	
	var detection = ghost_tower.get_node_or_null("DetectionRange")
	if detection:
		detection.monitoring = false

func finalize_placement():
	is_placing = false

	ghost_tower.modulate.a = 1.0
	ghost_tower.set_process(true)
	ghost_tower.set_physics_process(true)
	
	var detection = ghost_tower.get_node_or_null("DetectionRange")
	if detection:
		detection.monitoring = true
	
	ghost_tower = null

func cancel_placement():
	is_placing = false
	if ghost_tower:
		ghost_tower.queue_free() 
		ghost_tower = null
