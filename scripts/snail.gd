extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -200.0

@onready var snail_sprite: AnimatedSprite2D = $SnailSprite
@onready var in_shell_collision: CollisionShape2D = $InShellCollision
@onready var damage_collision: CollisionShape2D = $HitArea2D/DamageCollision
@onready var out_shell_collision: CollisionShape2D = $OutShellCollision
@onready var ray_cast_left: RayCast2D = %RayCastLeft
@onready var ray_cast_right: RayCast2D = %RayCastRight

@onready var default_pos_in_shell = in_shell_collision.position.x
@onready var default_pos_out_shell = out_shell_collision.position.x
@onready var default_pos_damage = damage_collision.position.x
var direction = 0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	elif is_on_floor() and direction == 0:
		snail_sprite.play("idle")
		in_shell_collision.disabled = false
		out_shell_collision.disabled = true
	else:
		snail_sprite.play("walking")
		in_shell_collision.disabled = true
		out_shell_collision.disabled = false
	set_move_route(delta)
	detect_wall()
	move_and_slide()

func detect_wall():
	if ray_cast_left.is_colliding():
		snail_sprite.flip_h = true
		in_shell_collision.position.x = default_pos_in_shell * -1
		out_shell_collision.position.x = default_pos_out_shell * -1
		damage_collision.position.x = default_pos_damage * -1
		direction = 1
	elif ray_cast_right.is_colliding():
		snail_sprite.flip_h = false
		in_shell_collision.position.x = default_pos_in_shell
		out_shell_collision.position.x = default_pos_out_shell
		damage_collision.position.x = default_pos_damage
		direction = -1

func set_move_route(delta):
	velocity.x = SPEED * direction * delta
