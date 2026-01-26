class_name MainGame3D
extends Node3D



@onready var main_menu := %MainMenu as MainMenu

@onready var main_game_2d := %MainGame as MainGame

@onready var animation_player := $AnimationPlayer as AnimationPlayer


func _ready() -> void:
	main_menu.start_game_pressed.connect(_start_game_pressed)
	main_menu.exit_game_pressed.connect(_shutdown_pressed)
	GlobalStates.return_to_main.connect(_return_to_main)
	
	main_menu.visible = true
	main_game_2d.visible = false


func power_on():
	main_menu.power_on()


func _start_game_pressed():
	animation_player.play("start_playing")
	GameManager.unpause()


func _return_to_main():
	animation_player.play_backwards("start_playing")
	main_game_2d.visible = false
	main_menu.visible = true


func _shutdown_pressed():
	if animation_player.is_playing() && animation_player.current_animation == "power_down":
		return
	
	animation_player.play("power_down")


func _quit():
	get_tree().quit()
