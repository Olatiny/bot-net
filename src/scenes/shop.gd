class_name Shop
extends PanelContainer

## Const IDS for purchase types
const ID_ENCRYPT := "encrypt"
const ID_FIREWALL = "firewall"
const ID_SENTINEL = "sentinel"
const ID_QUARRANTINE = "quarrantine"
const ID_PLAYER_UP = "player_up"
const ID_FIREWALL_UP = "firewall_up"
const ID_TOWER_UP = "tower_up"
const ID_SENTINEL_UP = "sentinel_up"
const ID_QUARRANTINE_UP = "quarrantine_up"


## Defines base prices for all items in game
const BASE_TYPE_PRICES: Dictionary[String, int] = {
	ID_ENCRYPT: 200,
	ID_FIREWALL: 400,
	ID_SENTINEL: 200,
	ID_QUARRANTINE: 300,
	ID_PLAYER_UP: 500,
	ID_FIREWALL_UP: 600,
	ID_TOWER_UP: 500,
	ID_SENTINEL_UP: 400,
	ID_QUARRANTINE_UP: 500
}

## Buttons mapped to respective IDs
@onready var button_id_dict: Dictionary[Button, String] = {
	%Encrypt: ID_ENCRYPT,
	%Firewall: ID_FIREWALL,
	%AimTower: ID_SENTINEL,
	%AOETower: ID_QUARRANTINE,
	%PlayerUp: ID_PLAYER_UP,
	%FirewallUpgrade: ID_FIREWALL_UP,
	%SentinelUpgrade: ID_SENTINEL_UP,
	%QuarrantineUpgrade: ID_QUARRANTINE_UP
}

## The current prices being used by the shop. Changes throughout game, resets when init_shop is called.
var current_prices: Dictionary[String, int]


## Whenever an upgrade is purchased, add this * current level to next upgrade price
@export var upgrade_cost_increment := 250


## Label for current player RAM
@onready var ram_label := %RamAmountLabel as RichTextLabel

## The shop button integration class
@onready var button_integration := %buttonintegration as ButtonIntegration


## Initializes buttons
func _ready() -> void:
	init_shop()
	toggle_shop_phase(false)
	
	for button: Button in button_id_dict.keys():
		button.text = button_id_dict[button].to_upper() + "\n" + str(_get_price_for_button(button)) + " RAM"


func toggle_shop_phase(toggle: bool):
	%UpgradeOptions.visible = toggle


## Updates button states and ram label
func _process(_delta: float):
	ram_label.text = "RAM: " + str(int(GameManager.player_ram))
	
	for button: Button in button_id_dict.keys():
		button.text = button_id_dict[button].to_upper() + "\n" + str(_get_price_for_button(button)) + " RAM"
		button.disabled = _get_price_for_button(button) > GameManager.player_ram || GameManager.game_board.is_folder_open


## Alias for getting the price corresponding with a particular button. returns -1 if button unmapped
func _get_price_for_button(button: Button) -> int:
	return current_prices.get(button_id_dict.get(button), -1)


## Initializes the shop to the base dictionary's values
func init_shop():
	current_prices = BASE_TYPE_PRICES.duplicate()


## Called by a button when it is pressed
func _button_pressed(button: Button = null):
	if !button_id_dict.has(button):
		return
	
	if GameManager.try_purchase(_get_price_for_button(button)):
		_purchase_selected(button_id_dict[button])


## Runs corresponding purchase/upgrade function
func _purchase_selected(purchase_type: String):
	GlobalStates.currency_changed.emit(-current_prices[purchase_type])
	current_prices[purchase_type] += upgrade_cost_increment
	
	# NOTE: necessary for upgrades particularly to have their own funcs because prims are pass by val
	match (purchase_type):
		ID_ENCRYPT: _encrypt_purchase()
		ID_FIREWALL: _firewall_purchase()
		ID_SENTINEL: _sentinel_purchase()
		ID_QUARRANTINE: _quarrantine_purchase()
		ID_PLAYER_UP: _player_up()
		ID_FIREWALL_UP: _firewall_up()
		ID_SENTINEL_UP: _sentinel_up()
		ID_QUARRANTINE_UP: _quarrantine_up()
		ID_TOWER_UP: _tower_up()


func _encrypt_purchase():
	GameManager.encrypt_charges += 1


func _firewall_purchase():
	button_integration._on_build_wall_button_pressed()
	_upgrade_wall_to_level(button_integration.ghost_tower, GameManager.firewall_level)


func _sentinel_purchase():
	button_integration._on_build_button_pressed()
	_upgrade_tower_to_level(button_integration.ghost_tower, GameManager.sentinel_tower_level)


func _quarrantine_purchase():
	button_integration._on_aoe_build_button_pressed()
	_upgrade_tower_to_level(button_integration.ghost_tower, GameManager.quarrantine_tower_level)


func _player_up():
	GameManager.player_level += 1


func _firewall_up():
	GameManager.firewall_level += 1
	
	var firewalls = get_tree().get_nodes_in_group("firewall")
	for wall in firewalls:
		if wall is Firewall:
			_upgrade_wall_to_level(wall, GameManager.firewall_level)


func _sentinel_up():
	GameManager.sentinel_tower_level += 1
	
	# Upgrades existing towers
	var towers = get_tree().get_nodes_in_group("towers")
	for tower in towers:
		if tower is Tower:
			_upgrade_tower_to_level(tower, GameManager.sentinel_tower_level)


func _quarrantine_up():
	GameManager.quarrantine_tower_level += 1
	
	# Upgrades existing towers
	var towers = get_tree().get_nodes_in_group("towers")
	for tower in towers:
		if tower is AreaTower:
			_upgrade_tower_to_level(tower, GameManager.quarrantine_tower_level)


func _upgrade_tower_to_level(tower, dest_level):
	while tower.upgrade_level < dest_level:
		tower.apply_upgrade()


func _upgrade_wall_to_level(wall: Firewall, dest_level):
	while wall.upgrade_level < dest_level:
		wall.upgrade_wall()


func _tower_up():
	pass
