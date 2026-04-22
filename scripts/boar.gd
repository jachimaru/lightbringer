extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -200.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		sprite.play("idle")

	move_and_slide()
