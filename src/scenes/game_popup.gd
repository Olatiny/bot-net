class_name GamePopup
extends PanelContainer


func _on_button_pressed() -> void:
	if !$AnimationPlayer.current_animation == "outro":
		$AnimationPlayer.play("outro")
