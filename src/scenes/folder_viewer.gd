class_name FolderViewer
extends ColorRect


## Folder Contents
@onready var folder_innards := %FolderInnards as FolderInnards

## animation player for open / close
@onready var animation_player := %AnimationPlayer as AnimationPlayer

## tolerance bar
@onready var tolerance_bar := %Tolerance as TextureProgressBar

## shield bar
@onready var shield_bar := %Shield as TextureProgressBar


## virus folder container scene ref
var VIRUS_FOLDER_CONTAINER_SCENE := preload("res://src/entities/virus_folder_container.tscn")


## Cached reference to the folder being loaded
var viewed_folder: GameFolder


## preview folder data
func _process(_delta: float) -> void:
	if !is_instance_valid(viewed_folder):
		return
	
	tolerance_bar.value = viewed_folder.tolerance
	shield_bar.value = viewed_folder.shield
	
	tolerance_bar.visible = tolerance_bar.value > 0
	shield_bar.visible = shield_bar.value > 0


## opens folder anim
func open_folder(folder: GameFolder):
	animation_player.play("open")
	viewed_folder = folder
	
	load_folder_contents()


## Called by animation player to load contents into scene
func load_folder_contents():
	for virus in viewed_folder.virus_list:
		if is_instance_valid(virus):
			add_virus_to_sim(virus)


func add_virus_to_sim(virus: Virus):
	if !is_instance_valid(viewed_folder) || !viewed_folder.virus_list.has(virus):
		return
	
	var container := VIRUS_FOLDER_CONTAINER_SCENE.instantiate() as VirusFolderContainer
	folder_innards.place_virus.call_deferred(container)
	container.add_virus.call_deferred(virus)
	virus.set_enabled.call_deferred(true)


func unload_folder_contents():
	for virus_container in folder_innards.playground.get_children():
		if virus_container is not VirusFolderContainer:
			continue
		
		virus_container = virus_container as VirusFolderContainer
		
		if is_instance_valid(virus_container.contained_virus):
			virus_container.contained_virus.call_deferred("reparent", viewed_folder)
			virus_container.contained_virus.set_enabled(false)
		
		virus_container.queue_free()


## closes folder anim
func close_folder():
	animation_player.play("close")
	GameManager.game_board.close_folder()
	unload_folder_contents()
	viewed_folder = null
