class_name Door
extends PathFollow2D


func _ready() -> void:
	set_state(true)


func set_state(is_open: bool):
	$Sprites/Open.visible = is_open
	$Sprites/Close.visible = !is_open


func place(ratio: float):
	progress_ratio = ratio
