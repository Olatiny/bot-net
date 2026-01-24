class_name GamePath
extends Path2D

var _backdoor_active := false
@onready var backdoor_timer := Timer.new()


func _ready() -> void:
	backdoor_timer.one_shot = true
	backdoor_timer.autostart = false
	backdoor_timer.wait_time = 5.0

	add_child(backdoor_timer)
	backdoor_timer.timeout.connect(_destroy_backdoor)


#creates a backdoor for the viruses to travel through
func create_backdoor() -> void:
	if (_backdoor_active):
		return
		
	_backdoor_active = true
	backdoor_timer.start()


func _destroy_backdoor() -> void:
	_backdoor_active = false
	
