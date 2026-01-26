class_name MainGame3D
extends Node3D



@onready var animation_player := $AnimationPlayer as AnimationPlayer



func power_on():
	pass


func _quit():
	get_tree().quit()
