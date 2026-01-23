# class_name: GlobalStates as Autoload
## Stores global defines used everywhere in project, such as common enums or global constants
extends Node


## Enum class for human-readable collision layering in code
enum COLLISION_LAYERS {
	PLAYER =    0b00001,
	VIRUS  =    0b00010,
	TOWER  =    0b00100,
	PATH   =    0b01000,
	FOLDER =    0b10000
}

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
