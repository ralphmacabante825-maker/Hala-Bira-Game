extends CharacterBody2D


const speed = 100.0

var last_direction: Vector2 = Vector2.RIGHT
var is_attacking: bool = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()
	
	if is_attacking:
		velocity = Vector2.ZERO
		return
	
	process_movement()
	process_animation()
	move_and_slide()

func process_movement() -> void:
	
	var direction := Input.get_vector("left", "right", "up", "down")
	
	if direction != Vector2.ZERO:
		velocity = direction * speed
		last_direction = direction
	else:
		velocity = Vector2.ZERO
	

#	-------------------------
#	Movement
#	-------------------------

func process_animation() -> void:
	if is_attacking:
		return
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
	
	

#	----------------------
#	Attack
#	----------------------

func attack() -> void:
	is_attacking = true
	player_animation("attack", last_direction)
	


func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking:
		is_attacking = false
