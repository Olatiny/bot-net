class_name WaveNotifier
extends Control


## Notification text
@onready var notification_label := $Notificaiton as RichTextLabel

## animation player for showing text
@onready var animation_player := $AnimationPlayer as AnimationPlayer


func _ready() -> void:
	GlobalStates.wave_started.connect(_on_wave_start)
	GlobalStates.wave_ended.connect(_on_wave_end)


func _process(_delta: float) -> void:
	if GameManager.wave_cooldown.is_stopped():
		return
	
	_on_wave_end(-1, int(GameManager.wave_cooldown.time_left), false)


func _on_wave_start(wave_idx: int):
	notification_label.text = "[shake rate=20.0 level=25 connected=1]WAVE        " + str(wave_idx) + "[/shake]"
	animation_player.play("show_and_fade")


func _on_wave_end(_wave_idx: int, time_remaining: int, reset_animation := true):
	notification_label.text = "[shake rate=20.0 level=25 connected=1]NEXT WAVE:  " + str(time_remaining)
	
	if reset_animation:
		animation_player.play("show")
