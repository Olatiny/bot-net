class_name Mouse
extends Node2D


var hovering:
	get():
		return _hovered_items > 0

var _hovered_items := 0

@export var clicked := false

@onready var anim_tree := $AnimationTree as AnimationTree

@onready var change_player := $RamChangePlayer as AnimationPlayer

@onready var change_label := $ChangeLabel as RichTextLabel


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	GlobalStates.mouse_hover.connect(_mouse_hover)
	GlobalStates.mouse_tier_change.connect(_mouse_tier_change)
	GlobalStates.currency_changed.connect(_currency_change)


func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	
	var shield_state = 1.0 if GameManager.encrypt_charges > 0 else 0.0
	
	anim_tree.set("parameters/Click/blend_position", shield_state)
	anim_tree.set("parameters/Idle/blend_position", shield_state)
	anim_tree.set("parameters/Hover/blend_position", shield_state)
	
	if Input.is_action_just_pressed("attack"):
		clicked = true


func _mouse_tier_change(new_tier: int):
	(material as ShaderMaterial).set_shader_parameter("dest_color_1", GlobalStates.get_tier_color(new_tier - 1))


func _on_area_2d_area_entered(_area: Area2D) -> void:
	_hovered_items += 1


func _on_area_2d_area_exited(_area: Area2D) -> void:
	_hovered_items -= 1


func _on_area_2d_body_entered(_body: Node2D) -> void:
	_hovered_items += 1


func _on_area_2d_body_exited(_body: Node2D) -> void:
	_hovered_items -= 1


func _mouse_hover(state: bool):
	_hovered_items += 1 if state else -1


func _currency_change(val: float):
	if val == 0:
		return
	
	var sign_str = "+" if val > 0 else "-"
	change_label.text = "[shake rate=20.0 level=25 connected=1]" + sign_str + str(int(abs(val))) + " RAM[/shake]"
	change_label.add_theme_color_override("default_color", Color("d34c4c") if sign_str == "-" else Color("1f9a45"))
	
	change_player.stop()
	change_player.play("flash")
