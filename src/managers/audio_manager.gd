#class_name AudioManager
extends Node2D


## master volume
@export var master_volume_linear: float

## Streams
@export_category("Music Streams")

## main men theme
@export var main_menu: AudioStream

## Reference to audio stream for shop theme with intro segment
@export var shop_with_intro: AudioStream

## Reference to looping segment of shop theme
@export var shop_without_intro: AudioStream

## Reference to audio stream for main theme with intro segment
@export var main_with_intro: AudioStream

## Reference to looping segment of main theme
@export var main_without_intro: AudioStream


@export_category("SFX Streams")

@export var hit_sfx: AudioStream

@export var startup_sfx: AudioStream

@export var mouse_click_sfx: AudioStream

@export var file_in_danger: AudioStream

@export var purchase_sfx: AudioStream

@export var death_sfx: AudioStream

@export var wave_clear_sfx: AudioStream

@export var crt_on_sfx: AudioStream

@export var place_sfx: AudioStream


## timer for fade length
@onready var fade_timer := $FadeTimer as Timer

## main menu player
@onready var main_menu_player := $MainMenuPlayer as AudioStreamPlayer

## shop player ref
@onready var shop_player := $ShopPlayer as AudioStreamPlayer

## main player ref
@onready var main_player := $MainPlayer as AudioStreamPlayer


var active_player: AudioStreamPlayer = null

var main_intro_played := false



## fade to shop
func fade_to_shop() -> void:
	fade_between_tracks(shop_player, shop_with_intro, active_player)


## fade to main
func fade_to_main() -> void:
	if main_intro_played:
		fade_between_tracks(main_player, main_without_intro, active_player)
	else:
		fade_between_tracks(main_player, main_with_intro, active_player)
		main_intro_played = true


func fade_to_menu() -> void:
	fade_between_tracks(main_menu_player, main_menu, active_player)


## fade between tracks
func fade_between_tracks(in_track: AudioStreamPlayer, in_stream: AudioStream, out_track: AudioStreamPlayer):
	if out_track != in_track:
		fade_out(out_track)
	
	fade_in(in_track, in_stream)


## fade in a track with a stream
func fade_in(player: AudioStreamPlayer, stream: AudioStream):
	player.stream = stream
	player.play()
	player.volume_linear = 0
	
	active_player = player
	
	var tween := get_tree().create_tween()
	tween.tween_property(player, "volume_linear", 1 * master_volume_linear, .1)


func set_volume(new_vol: float):
	main_player.volume_linear = new_vol
	shop_player.volume_linear = new_vol
	main_menu_player.volume_linear = new_vol


## fade a track out
func fade_out(player: AudioStreamPlayer):
	if !is_instance_valid(player):
		return
	
	var tween := get_tree().create_tween()
	tween.tween_property(player, "volume_linear", 0, .1)
	tween.tween_callback(player.stop)


## set music paused state (high pass)
func pause(pause_state: bool):
	if pause_state: 
		shop_player.bus = "Paused"
		main_player.bus = "Paused"
		main_menu_player.bus = "Paused"
	else:
		shop_player.bus = "Music"
		main_player.bus = "Music"
		main_menu_player.bus = "Music"


func start_music() -> void:
	main_intro_played = false
	shop_player.stream = shop_with_intro
	main_player.stream = main_with_intro
	main_menu_player.stream = main_menu
	fade_to_main()


## stop the music
func stop_music():
	fade_out(shop_player)
	fade_out(main_player)


## loop to non intro version
func _on_shop_player_finished() -> void:
	if shop_player != active_player:
		return
	
	shop_player.stream = shop_without_intro
	shop_player.play()


## loop to non intro version
func _on_main_player_finished() -> void:
	if main_player != active_player:
		return
	
	main_player.stream = main_without_intro
	main_player.play()


func _on_main_menu_player_finished() -> void:
	if main_menu_player != active_player:
		return
	
	main_menu_player.stream = main_menu
	main_menu_player.play()


##################################
###     SFX MANAGEMENT         ###
##################################


func sfx_play_virus_hit():
	_sfx_one_shot(hit_sfx, 1, randf_range(.90, 1.1))


func sfx_play_startup_sfx():
	_sfx_one_shot(startup_sfx)


func sfx_play_mouse_click_sfx():
	_sfx_one_shot(mouse_click_sfx)


func sfx_play_file_in_danger():
	_sfx_one_shot(file_in_danger)


func sfx_play_purchase_sfx():
	_sfx_one_shot(purchase_sfx)


func sfx_play_death_sfx():
	_sfx_one_shot(death_sfx, 1, randf_range(.90, 1.1))


func sfx_play_wave_clear_sfx():
	_sfx_one_shot(wave_clear_sfx)


func sfx_play_crt_on_sfx():
	_sfx_one_shot(crt_on_sfx)


func sfx_play_place_sfx():
	_sfx_one_shot(place_sfx, 3.5)



func _sfx_one_shot(in_stream: AudioStream, volume_mod := 1.0, pitch_mod := 1.0):
	var sfx_player := AudioStreamPlayer.new()
	get_tree().root.add_child(sfx_player)
	sfx_player.stream = in_stream
	sfx_player.bus = main_player.bus
	sfx_player.volume_linear = 1 * master_volume_linear * volume_mod
	sfx_player.pitch_scale = pitch_mod
	sfx_player.play()
	sfx_player.finished.connect(sfx_player.queue_free)
