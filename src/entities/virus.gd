class_name Virus
extends Node2D


## The speed of movement for the virus along the path
@export var speed = 0.15

## The max scale of the virus based on health
@export var max_scale = 1.5

## The min scale of the virus based on health == 1
@export var min_scale = 1

## The maximum health of the virus
@export var max_health = 5

## The current health of the virus
@export var health = 5

## The current "tier" of this virus NOTE: This might be uneccesary to track this way
@export var tier = 1:
	set(value):
		tier = value
		
		if is_instance_valid($Sprite2D):
			$Sprite2D.material.set_shader_parameter("dest_color_1", GlobalStates.get_tier_color(tier))

## The base amount of RAM awarded for killing
@export var ram_award := 25


## state for defeated animation playing
var defeated := false

## enabled state, basically if this guy's in a folder disable collision / hide
var enabled := true

## private state for mouse over
var _mouse_over := false

## Animation Player
@onready var animation_player := $AnimationPlayer as AnimationPlayer

## hit stun timer (damage ignored)
@onready var hitstun_timer := $Hitstun as Timer


func _process(delta: float) -> void:
	if !enabled || !is_instance_valid(get_parent()) || !get_parent().has_method("move_virus"):
		return
	
	get_parent().move_virus(delta)
	
	if _mouse_over && Input.is_action_just_pressed("attack"):
		process_attack(GameManager.player_attack_damage)
	
	var curr_scalar = lerpf(min_scale, max_scale, float(health) / float(max_health))
	scale = Vector2(curr_scalar, curr_scalar)


## processes attack damage
func process_attack(attack_damage: int):
	if !hitstun_timer.is_stopped() || defeated:
		return
	
	hitstun_timer.start()
	
	health -= attack_damage
	health = max(health, 0)
	
	if health > 0:
		GameManager.add_ram(GameManager.ram_income)
		animation_player.stop()
		animation_player.play("ouchie")
	else:
		defeated = true
		GameManager.add_ram(ram_award * tier * GameManager.player_level)
		GlobalStates.virus_defeated.emit(self)
		# NOTE: this animation calls queue_free when it finishes
		animation_player.stop()
		animation_player.play("defeat")
	
	await animation_player.animation_finished


## Loads virus from data
func load_from_data(data: VirusData):
	max_health = data.max_health
	health = data.curr_health
	tier = data.tier


## Handles collisions
func _on_area_entered(other_area: Area2D) -> void:
	if other_area.get_parent() is GameFolder:
		try_add_to_folder(other_area.get_parent())
		return


## Adds a virus to a folder 
## 
## essentially, deletes this node and puts data into folder.
## when folder opened, it repopulates with viruses of corresponding tracked data
func try_add_to_folder(collided_folder: GameFolder):
	# if any of these states, don't skip this folder.
	if [GameFolder.FOLDER_TYPE.DEFEATED, GameFolder.FOLDER_TYPE.ROOT].has(collided_folder.current_state):
		return
	
	collided_folder.add_virus_to_folder(self)


func set_enabled(enabled_state: bool):
	enabled = enabled_state
	
	visible = enabled
	$Area2D.set_deferred("monitoring", enabled)
	$Area2D.set_deferred("monitorable", enabled)


## mouse over event
func _mouse_entered() -> void:
	_mouse_over = true
	GlobalStates.mouse_hover.emit(true)


## mouse exit event
func _mouse_exited() -> void:
	_mouse_over = false
	GlobalStates.mouse_hover.emit(false)


func _exit_tree() -> void:
	if _mouse_over:
		_mouse_exited()
