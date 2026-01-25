# class_name: GlobalStates as Autoload
## Stores global defines used everywhere in project, such as common enums or global constants
extends Node


## Enum class for human-readable collision layering in code
enum COLLISION_LAYERS {
	PLAYER         =   0b000001,
	VIRUS          =   0b000010,
	TOWER          =   0b000100,
	PATH           =   0b001000,
	FOLDER         =   0b010000,
	MOUSE_DETECT   =   0b100000
}

## Global dict of colors for tiers
const TIER_COLORS: Array[Color] = [
	Color("bc0463"),
	Color("a54902"),
	Color("bba600"),
	Color("1d7e1a"),
	Color("04767f"),
	Color("5f31f9"),
	Color("aa04a7"),
]

## global function to get a correct tier color
func get_tier_color(tier: int):
	return TIER_COLORS[tier % (TIER_COLORS.size())]


#####################
### TERMINAL USRS ###
#####################

const USR_SYSTEM := "sys_message"

const USR_WARN := "sys_warning"

const USR_VIRUS := "usr/M.A.L."

const USR_DEFAULT := "usr_default"

const SHOP_NAME := "task_man"


######################
### GLOBAL SIGNALS ###
######################

@warning_ignore("unused_signal")
signal folder_opened(folder: GameFolder)

@warning_ignore("unused_signal")
signal folder_closed(folder: GameFolder)

@warning_ignore("unused_signal")
signal virus_defeated(virus: Virus)

@warning_ignore("unused_signal")
signal mouse_hover(state: bool)

@warning_ignore("unused_signal")
signal mouse_tier_change(new_tier: int)
