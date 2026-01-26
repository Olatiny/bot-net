class_name PauseMenu
extends PanelContainer



@onready var score_text := $"VBoxContainer/Score Text" as RichTextLabel



#func _process(_delta: float) -> void:
	#set_game_over_time(GameManager.get_time_string())


func set_game_over_time(time_string: String):
	score_text.text = "SURVIVAL TIME: [shake rate=5.0 level=25 connected=1]" + time_string + "[/shake]"


func _restart_pressed() -> void:
	GameManager.unpause()


func _quit_pressed() -> void:
	GlobalStates.return_to_main.emit()
