extends CharacterBody2D

@export var move_distance: float
@export var move_time: float


const SPEED = 100.0
const JUMP_VELOCITY = -400.0

@onready var body_collision_1: CollisionShape2D = $BodyCollision1
@onready var body_collision_2: CollisionShape2D = $BodyCollision2
@onready var stinger_collision: CollisionShape2D = $HitArea2D/StingerCollision
@onready var attack_ray_cast: ShapeCast2D = $AttackRayCast
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var direction = 0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		sprite.play("idle")
	
	set_move_route(delta)
	#move_and_slide()

func set_move_route(delta):
	if direction != -1:
		position.x += move_distance * delta * direction
		print("position: ", position.x)
		await get_tree().create_timer(move_time).timeout
		print("timer up")
		direction = -1
		print("direction: ", direction)
	if direction == -1:
		position.x += move_distance * delta * direction
		print("position: ", position.x)
		await get_tree().create_timer(move_time).timeout
		print("timer up")
		direction = 1
		print("direction: ", direction)

#func detect_light(delta):
	#var collider = light_detector.get_collider()
	#if light_detector.is_colliding():
		#direction = direction * -1
		#if direction == 1:
			#snail_sprite.flip_h = true
			#light_detector.target_position.x = 47.0
			#in_shell_collision.position.x = default_pos_in_shell * -1
			#out_shell_collision.position.x = default_pos_out_shell * -1
			#damage_collision.position.x = default_pos_damage * -1
		#if direction == -1:
			#snail_sprite.flip_h = false
			#light_detector.target_position.x = -47.0
			#in_shell_collision.position.x = default_pos_in_shell
			#out_shell_collision.position.x = default_pos_out_shell
			#damage_collision.position.x = default_pos_damage
		#if collider.is_in_group("cone_area"):
			#if direction == 1:
				#snail_sprite.flip_h = true
				#light_detector.target_position.x = 47.0
				#in_shell_collision.position.x = default_pos_in_shell * -1
				#out_shell_collision.position.x = default_pos_out_shell * -1
				#damage_collision.position.x = default_pos_damage * -1
				#direction = direction * -1
			#if direction == -1:
				#snail_sprite.flip_h = false
				#light_detector.target_position.x = -47.0
				#in_shell_collision.position.x = default_pos_in_shell
				#out_shell_collision.position.x = default_pos_out_shell
				#damage_collision.position.x = default_pos_damage
				#direction = direction * -1
			#set_physics_process(false)
			#damage_collision.disabled = true
			#snail_sprite.play("in_shell")
			#await get_tree().create_timer(2.0).timeout
			#snail_sprite.play("idle")
			#await get_tree().create_timer(2.0).timeout
			#snail_sprite.play("peak")
			#await get_tree().create_timer(1.5).timeout
			#snail_sprite.play("out_shell")
			#await get_tree().create_timer(2.0).timeout
			#direction = direction * -1
			#set_physics_process(true)
			#damage_collision.disabled = false
