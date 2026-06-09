extends CharacterBody2D

const speed = 300.0

var last_direction: Vector2 = Vector2.RIGHT
var is_attacking: bool = false
var can_move = true

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(_delta: float) -> void:

	if !can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()

	if not is_attacking:
		process_movement()
		process_animation()
	else:
		velocity = Vector2.ZERO

	move_and_slide()


func process_movement() -> void:

	var direction := Input.get_vector("left", "right", "up", "down")

	if direction != Vector2.ZERO:
		velocity = direction * speed
		last_direction = direction
	else:
		velocity = Vector2.ZERO


func process_animation() -> void:

	if velocity != Vector2.ZERO:
		player_animation("run", last_direction)
	else:
		player_animation("idle", last_direction)


func player_animation(prefix: String, dir: Vector2) -> void:

	if dir.x != 0:
		animated_sprite_2d.flip_h = dir.x < 0
		animated_sprite_2d.play(prefix + "_right")
	elif dir.y < 0:
		animated_sprite_2d.play(prefix + "_up")
	elif dir.y > 0:
		animated_sprite_2d.play(prefix + "_down")


func attack() -> void:

	is_attacking = true

	if last_direction.x != 0:
		animated_sprite_2d.flip_h = last_direction.x < 0
		animated_sprite_2d.play("attack_right")
	elif last_direction.y < 0:
		animated_sprite_2d.play("attack_up")
	else:
		animated_sprite_2d.play("attack_down")

	await get_tree().create_timer(0.3).timeout

	is_attacking = false
