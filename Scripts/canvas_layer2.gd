extends CanvasLayer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		var paused = not get_tree().paused
		get_tree().paused = paused
		$IngameUi.visible = paused

func _on_help_button_pressed():
		get_tree().paused = false
		visible = false
