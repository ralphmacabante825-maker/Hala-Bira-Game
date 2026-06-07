extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":

		body.can_move = false

		print("Cutscene started")

		await get_tree().create_timer(3.0).timeout

		body.can_move = true

		print("Cutscene ended")
