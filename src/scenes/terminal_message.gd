class_name TerminalMessage
extends HBoxContainer

## signals when animation completed
@warning_ignore("unused_signal") #NOTE: it is used in animation player
signal animation_complete


## Tracks whether this is currently animating
var intro_interrupted := false

## User Label
@onready var user_label := $UserLabel as RichTextLabel

## Message Label
@onready var message_label := $UserLabel as RichTextLabel

## text fill animating status
var message_received := false

## skip animation
var skip_anim := false


func hide_text():
	modulate.a = 0


func set_message(in_message: String):
	$MessageLabel.text = in_message


func set_user(in_user: String):
	$UserLabel.text = in_user + " >"


## Plays a brief typing animation for the terminal message
func animate_message(messaged := false):
	message_received = messaged


func _on_message_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
