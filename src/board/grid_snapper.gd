@tool
class_name GridSnapper
extends Node2D

@export var grid_size := Vector2(1, 1)
@export var grid_offset := Vector2(0, 0)
@export var tile_size := Vector2(24, 24)
@export var disabled := false

@onready var parent = get_parent()

var _position_old


func _ready():
	if !Engine.is_editor_hint():
		return
	
	_position_old = parent.position


## used to snap connectors to valid positions
func _process(_delta: float):
	if !Engine.is_editor_hint() || disabled:
		return
	
	# update only if value changed
	if _position_old == parent.position:
		return
	
	var snap_factor = tile_size * grid_size
	
	parent.position = Vector2(
		roundf(parent.position.x/snap_factor.x) * snap_factor.x, 
		roundf(parent.position.y/snap_factor.y) * snap_factor.y
	) + grid_offset
	
	_position_old = parent.position
