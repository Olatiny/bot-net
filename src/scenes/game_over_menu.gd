class_name GameOverMenu
extends PanelContainer



@onready var score_text := $"VBoxContainer/Score Text" as RichTextLabel


func set_game_over_time(time_string: String):
	score_text.text = "SURVIVAL TIME: [shake rate=5.0 level=25 connected=1]" + time_string + "[/shake]"


func _restart_pressed() -> void:
	GameManager.restart_game()


func _quit_pressed() -> void:
	GameManager.quit_game()
