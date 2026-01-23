class_name FolderViewer
extends PanelContainer


## Folder Contents
@onready var folder_innards := %FolderInnards as FolderInnards

## animation player for open / close
@onready var animation_player := $AnimationPlayer as AnimationPlayer


## virus folder container scene ref
var VIRUS_FOLDER_CONTAINER_SCENE := preload("res://src/entities/virus_folder_container.tscn")


## Cached reference to the folder being loaded
var viewed_folder: GameFolder


## opens folder anim
func open_folder(folder: GameFolder):
	animation_player.play("open")
	viewed_folder = folder
	
	load_folder_contents()

## Called by animation player to load contents into scene
func load_folder_contents():
	for virus in viewed_folder.virus_list:
		var container := VIRUS_FOLDER_CONTAINER_SCENE.instantiate() as VirusFolderContainer
		folder_innards.place_virus(container)
		container.add_virus(virus)
		virus.set_enabled(true)


func unload_folder_contents():
	for virus_container in folder_innards.playground.get_children():
		if virus_container is not VirusFolderContainer:
			continue
		
		virus_container = virus_container as VirusFolderContainer
		viewed_folder.add_child(virus_container.contained_virus)
		virus_container.contained_virus.set_enabled(false)
		virus_container.queue_free()


## closes folder anim
func close_folder():
	animation_player.play("close")
	GameManager.game_board.close_folder()
	viewed_folder = null
