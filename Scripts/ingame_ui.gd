extends Control

func _ready():
	visible = false
	set_process_unhandled_input(true)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		var paused = not get_tree().paused
		get_tree().paused = paused
		visible = paused


func _on_help_button_pressed():
		get_tree().paused = false
		visible = false
