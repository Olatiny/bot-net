class_name FolderInnards
extends Node2D


## Folder Being Displayed
var folder: GameFolder = null

## Virus Playground
@onready var playground := $Playground as Node2D


func place_virus(in_container: VirusFolderContainer):
	playground.add_child(in_container)
	in_container.position = position + Vector2(100, 100)


func unload_folder():
	var new_virus_data: Array[VirusData] = []
	
	for child in playground.get_children():
		child = child as VirusFolderContainer
		
		## TODO: Update folder data to current data
		
		child.queue_free()
	
	folder.virus_data_list = new_virus_data.duplicate_deep(Resource.DEEP_DUPLICATE_INTERNAL)
	folder = null
