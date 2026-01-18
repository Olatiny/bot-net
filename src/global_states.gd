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
