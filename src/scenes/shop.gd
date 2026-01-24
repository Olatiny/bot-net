class_name Shop
extends PanelContainer


@onready var ram_label := %RamAmountLabel as RichTextLabel


@export var button_price_dict: Dictionary[Button, float]


func _ready() -> void:
	for button: Button in button_price_dict.keys():
		button.text = button.name.to_upper() + "\n" + str(int(button_price_dict.get(button))) + " RAM"


func _process(_delta: float):
	ram_label.text = "RAM: " + str(int(GameManager.player_ram))
	
	for button: Button in button_price_dict.keys():
		button.disabled = button_price_dict.get(button) > GameManager.player_ram || GameManager.game_board.is_folder_open


func _button_pressed(button: Button = null):
	if button_price_dict.has(button):
		GameManager.try_purchase(button_price_dict.get(button))


func upgrade_click():
	GameManager.player_attack_damage += 1


func _on_encrypt_pressed() -> void:
	GameManager.encrypt_charges += 1
