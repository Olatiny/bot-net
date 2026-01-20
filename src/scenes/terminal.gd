class_name Terminal
extends PanelContainer

#####################
### LOCAL DEFINES ###
#####################

var system_name := GlobalStates.USR_SYSTEM

var virus_name := GlobalStates.USR_VIRUS

var user_name := GlobalStates.USR_DEFAULT

var shop_name := GlobalStates.SHOP_NAME

var warning_name := GlobalStates.USR_WARN


var USR_DEFAULT_COLORS := {
	system_name: "1d7e1a",
	warning_name: "cb2a5e",
	virus_name: "9b79ad",
	user_name: "2bb5e9",
	shop_name: "e9c02b"
}


## Scene ref for terminal message
@onready var MESSAGE_SCENE := preload("res://src/scenes/terminal_message.tscn")

## The current message
@onready var current_message := $HBoxContainer/ScrollContainer/MessageContainer/TerminalMessage as TerminalMessage

## message container
@onready var message_container := $HBoxContainer/ScrollContainer/MessageContainer as VBoxContainer

## scroll container
@onready var scroll_container := $HBoxContainer/ScrollContainer as ScrollContainer



## TODO: this is so it auto scrolls down. pretty sure this is a bad solution but something something it doesn't just work in the instantiate func
func _process(_delta: float) -> void:
	scroll_container.scroll_vertical += 100


## Push a BBCode-enabled string to the terminal
## TODO: Works good enough for now but will fix minor issues later
func push_new_message(message: String, usr := "usr_default"):
	if current_message.message_received:
		current_message.skip_anim = true
		_init_curr_message()
		push_new_message(message, usr)
		return
	
	_push_msg_internal(message, usr)
	
	var curr_cache := current_message
	await curr_cache.animation_complete
	
	if !curr_cache.skip_anim:
		_init_curr_message()


func _push_msg_internal(message: String, usr: String):
	current_message.user_label.custom_minimum_size.x = usr.length() * 20 ## NOTE: this number is quite magical
	
	current_message.hide_text()
	
	if USR_DEFAULT_COLORS.has(usr):
		current_message.user_label.add_theme_color_override("default_color", Color(USR_DEFAULT_COLORS[usr]))
		current_message.message_label.add_theme_color_override("default_color", Color(USR_DEFAULT_COLORS[usr]))
	
	current_message.set_message(message)
	current_message.set_user(usr)
	
	current_message.animate_message(true)


func _init_curr_message():
	current_message = MESSAGE_SCENE.instantiate()
	message_container.add_child(current_message)
	
	## Adjust scroll automatically
	#scroll_container.scroll_vertical += 1000
	#
	#scroll_container.update_minimum_size()
	#scroll_container.force_update_transform()
