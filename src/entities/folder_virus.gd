## Representation of a virus in a folder. 
##
## These share data of the viruses that entered, but behave differently while inside a folder, 
## hence the different class.
class_name FolderVirus
extends CharacterBody2D


## A copy of the virus data this virus represents
var virus_data: VirusData

## The 
var owning_folder: GameFolder

var folder_data_idx := -1
