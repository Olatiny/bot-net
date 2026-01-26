## NOTE: THIS IS A REALLY NON STANDARD / BAD WAY TO DO THIS !!! UH OH like Zoinks SCOOB that's some Janky Jam Code!
## I just needed a way to patch this in for the game jam within the 3D scene haha
## Hope this makes sense!
class_name MainMenu
extends CanvasLayer


signal start_game_pressed()

signal exit_game_pressed()



func start_game():
	start_game_pressed.emit()
	process_mode = Node.PROCESS_MODE_DISABLED


func end_game():
	exit_game_pressed.emit()
	process_mode = Node.PROCESS_MODE_DISABLED
