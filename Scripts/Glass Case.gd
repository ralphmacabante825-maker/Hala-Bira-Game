extends Area2D

var player_near = false

@export var dialogue_resource: DialogueResource

func _on_body_entered(body):
	if body.name == "Player":
		player_near = true

func _on_body_exited(body):
	if body.name == "Player":
		player_near = false

var dialogue_open = false

func _process(_delta):
	if player_near and Input.is_action_just_pressed("interact"):
		DialogueManager.show_dialogue_balloon(
			dialogue_resource,
			"artifact"
		)
