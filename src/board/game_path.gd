class_name GamePath
extends Path2D


@export var backdoor_start := 0.35
@export var backdoor_end := 0.65

var _backdoor_active := false
@onready var backdoor_timer := Timer.new()

var start_door: Door = null
var end_door: Door = null

const DOOR_SCENE := preload("res://src/scenes/door.tscn")


func _ready() -> void:
	backdoor_timer.one_shot = true
	backdoor_timer.autostart = false
	backdoor_timer.wait_time = 10

	add_child(backdoor_timer)
	backdoor_timer.timeout.connect(_destroy_backdoor)


#creates a backdoor for the viruses to travel through
func create_backdoor() -> void:
	if (_backdoor_active):
		return
	
	start_door = DOOR_SCENE.instantiate() as Door
	end_door = DOOR_SCENE.instantiate() as Door
	
	add_child(start_door)
	add_child(end_door)
	
	start_door.place(backdoor_start)
	end_door.place(backdoor_end)
	
	_backdoor_active = true
	backdoor_timer.start()


func _destroy_backdoor() -> void:
	_backdoor_active = false
	start_door.queue_free()
	end_door.queue_free()
