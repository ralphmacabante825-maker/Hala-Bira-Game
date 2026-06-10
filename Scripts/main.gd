extends Node2D

@onready var car: Node2D = $car
@onready var player: CharacterBody2D = $Base/Player

func _ready():
	start_cutscene()

func start_cutscene():

	player.set_physics_process(false)
	# Hide player at the beginning
	player.visible = false
	
	# Move car
	var car_tween = create_tween()

	car_tween.tween_property(
		car,
		"position",
		Vector2(280, car.position.y),
		2.0
	)

	await car_tween.finished
	
	# Wait 1 second after car stops
	await get_tree().create_timer(1.0).timeout
	
	# Spawn player beside car
	player.position = Vector2(
		195, 320
	)

	player.visible = true
	
	# Face right and idle
	player.animated_sprite_2d.play("idle_right")
	# Pause for 1 second
	await get_tree().create_timer(3.0).timeout
	
	# Start running animation
	player.animated_sprite_2d.play("run_right")

	# Walk player to museum
	var player_tween = create_tween()

	player_tween.tween_property(
	player,
	"position",
	Vector2(603, 256),
	3.0
)

	await player_tween.finished
	player.animated_sprite_2d.play("idle_up")
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://Scenes/museum.tscn")
	player.set_physics_process(true)
	print("Cutscene finished")
