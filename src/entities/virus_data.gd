class_name VirusData
extends Resource


@export var max_health: int

@export var curr_health: int

@export var tier: int

var progress_ratio: float


func _init(in_max_hp: int, in_curr_health: int, in_tier: int, in_progress_ratio: float) -> void:
	max_health = in_max_hp
	curr_health = in_curr_health
	tier = in_tier
	progress_ratio = in_progress_ratio
