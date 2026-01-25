#class_name AudioManager
extends Node2D


## master volume
@export var master_volume_linear: float

## Streams
@export_category("Audio Streams")

## Reference to audio stream for shop theme with intro segment
@export var shop_with_intro: AudioStream

## Reference to looping segment of shop theme
@export var shop_without_intro: AudioStream

## Reference to audio stream for main theme with intro segment
@export var main_with_intro: AudioStream

## Reference to looping segment of main theme
@export var main_without_intro: AudioStream




## timer for fade length
@onready var fade_timer := $FadeTimer as Timer

## shop player ref
@onready var shop_player := $ShopPlayer as AudioStreamPlayer

## main player ref
@onready var main_player := $MainPlayer as AudioStreamPlayer


var main_intro_played := false



### Load up streams and start main
#func _ready() -> void:
	#start_music()


## fade to shop
func fade_to_shop() -> void:
	fade_between_tracks(shop_player, shop_with_intro, main_player)


## fade to main
func fade_to_main() -> void:
	if main_intro_played:
		fade_between_tracks(main_player, main_without_intro, shop_player)
	else:
		fade_between_tracks(main_player, main_with_intro, shop_player)
		main_intro_played = true


## fade between tracks
func fade_between_tracks(in_track: AudioStreamPlayer, in_stream: AudioStream, out_track: AudioStreamPlayer):
	fade_in(in_track, in_stream)
	fade_out(out_track)


## fade in a track with a stream
func fade_in(player: AudioStreamPlayer, stream: AudioStream):
	player.stream = stream
	player.play()
	player.volume_linear = 0
	
	var tween := get_tree().create_tween()
	tween.tween_property(player, "volume_linear", 1 * master_volume_linear, .1)


## fade a track out
func fade_out(player: AudioStreamPlayer):
	var tween := get_tree().create_tween()
	tween.tween_property(player, "volume_linear", 0, .1)
	tween.tween_callback(player.stop)


## set music paused state (high pass)
func pause(pause_state: bool):
	if pause_state:
		shop_player.bus = "Paused"
		main_player.bus = "Paused"
	else:
		shop_player.bus = "Music"
		main_player.bus = "Music"


func start_music() -> void:
	main_intro_played = false
	shop_player.stream = shop_with_intro
	main_player.stream = main_with_intro
	fade_to_main()


## stop the music
func stop_music():
	fade_out(shop_player)
	fade_out(main_player)


## loop to non intro version
func _on_shop_player_finished() -> void:
	shop_player.stream = shop_without_intro
	shop_player.play()


## loop to non intro version
func _on_main_player_finished() -> void:
	main_player.stream = main_without_intro
	main_player.play()
