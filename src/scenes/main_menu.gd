## NOTE: THIS IS A REALLY NON STANDARD / BAD WAY TO DO THIS !!! UH OH like Zoinks SCOOB that's some Janky Jam Code!
## I just needed a way to patch this in for the game jam within the 3D scene haha
## Hope this makes sense!
class_name MainMenu
extends CanvasLayer


signal start_game_pressed()

signal exit_game_pressed()


@export var game_scene: MainGame

@onready var anim_player := $AnimationPlayer as AnimationPlayer

var shutdown_pressed := false

@onready var init_master_volume = AudioManager.master_volume_linear


func power_on() -> void:
	if anim_player.is_playing() || shutdown_pressed:
		return
	
	#AudioManager.pause(true)
	anim_player.play("reveal")
	
	$Control/PanelContainer2/MainPanel.visible = true
	$Control/PanelContainer2/Credit.visible = false
	$Control/PanelContainer2/Prefs.visible = false


func play_crt_start_sound():
	AudioManager.sfx_play_crt_on_sfx()


func play_startup_sound():
	AudioManager.sfx_play_startup_sfx()


func play_crt_off_sound():
	AudioManager.sfx_play_crt_off_sfx()


func start_music():
	AudioManager.fade_to_menu()


func start_game():
	if anim_player.is_playing() || shutdown_pressed:
		return
	
	AudioManager.start_music()
	AudioManager.pause(false)
	start_game_pressed.emit()
	
	visible = false
	game_scene.start_game()
	game_scene.visible = true


func end_game():
	if anim_player.is_playing() || shutdown_pressed:
		return
	
	AudioManager.stop_music()
	shutdown_pressed = true
	
	exit_game_pressed.emit()
	anim_player.play("shutdown")


func _on_close_credits_pressed() -> void:
	$Control/PanelContainer2/Credit.visible = false
	$Control/PanelContainer2/MainPanel.visible = true


func _volume_slider_changed(value: float) -> void:
	AudioManager.set_volume(init_master_volume * value)


func _prefs_exit_presed() -> void:
	$Control/PanelContainer2/Prefs.visible = false
	$Control/PanelContainer2/MainPanel.visible = true


func _on_toggle_fullscreen_pressed() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED) 
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_settings_pressed() -> void:
	$Control/PanelContainer2/Prefs.visible = true
	$Control/PanelContainer2/MainPanel.visible = false


func _on_credits_pressed() -> void:
	$Control/PanelContainer2/Credit.visible = true
	$Control/PanelContainer2/MainPanel.visible = false
