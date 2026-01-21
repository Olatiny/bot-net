## A base class for the viruses. 
## Extends path follow 2D so they can automatically follow a path using 
## `progress_ratio`
class_name Virus
extends PathFollow2D


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
@export var tier = 1


## state for defeated animation playing
var defeated := false

## private state for mouse over
var _mouse_over := false

## Animation Player
@onready var animation_player := $AnimationPlayer as AnimationPlayer

## hit stun timer (damage ignored)
@onready var hitstun_timer := $Hitstun as Timer


func _process(delta: float) -> void:
	_move_virus(delta)
	
	if _mouse_over && Input.is_action_just_pressed("attack"):
		process_attack(GameManager.player_attack_damage)


func _move_virus(delta: float):
	if get_parent() is Path2D:
		progress_ratio += delta * speed
		if get_parent()._backdoor_active and progress_ratio >= 0.2 and progress_ratio <= 0.24:
			progress_ratio = 0.75
	
	# interpolates scale based on current health out of maximum
	var curr_scalar = lerpf(min_scale, max_scale, float(health) / float(max_health))
	scale = Vector2(curr_scalar, curr_scalar)


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
	
	collided_folder.add_virus_data(convert_to_data())
	queue_free()


## processes attack damage
func process_attack(attack_damage: int):
	if !hitstun_timer.is_stopped() || defeated:
		return
	
	hitstun_timer.start()
	
	health -= attack_damage
	
	if health > 0:
		animation_player.stop()
		animation_player.play("ouchie")
	else:
		defeated = true
		# NOTE: this animation calls queue_free when it finishes
		animation_player.stop()
		animation_player.play("defeat")
	
	await animation_player.animation_finished


## Converts virus to data
func convert_to_data() -> VirusData:
	return VirusData.new(max_health, health, tier, progress_ratio)


## Loads virus from data
func load_from_data(data: VirusData):
	max_health = data.max_health
	health = data.curr_health
	tier = data.tier
	progress_ratio = data.progress_ratio


func _mouse_entered() -> void:
	_mouse_over = true


func _mouse_exited() -> void:
	_mouse_over = false
