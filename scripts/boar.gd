extends CharacterBody2D

#region
#Steps:
#Boar patrols or stays idle. use export var to decide which one?
#	export var for patrol distance.
#Boar sees player. Check if Gamemanager.in_light. if not, proceed to charge player.
#	play run animation, move Boar toward player using same formula as Bee's get_target, Boar moves at SPEED * 2.
#		Note: Boar should continue running past player into a wall if player moves out of the way.
#			If Boar runs into wall, it gets stunned for a number of seconds (export var, stun_time?) 
#			and hitbox collision is turned off.
#	If Gamemanager.in_light == true, Boar charges up until its light_detector detects light.
#		If light_detector detects a collider from cone_area, get_stunned(stun_time).
#			Otherwise, Boar stops at edge of light_area collision for a number of seconds. var wait_time?
#			then proceeds back to it's starting position and resumes patrol.
#Use move_toward() to move Boar or tween?
#endregion

@export var stun_time: float
@export var patrol_distance: float
@export var patrol_time: float
@export var patrolling: bool #True, this Boar patrols equal to patrol_distance. False, it stays idle.

@onready var hit_area_2d: HitArea2D = %HitArea2D
@onready var light_detector: RayCast2D = $LightDetector
@onready var wall_detector: RayCast2D = $WallDetector
@onready var vision: RayCast2D = $Vision
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var body_lower: CollisionShape2D = $BodyLower
@onready var body_upper: CollisionShape2D = $BodyUpper
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var tusk: CollisionShape2D = $HitArea2D/Tusk
@onready var eyes: PointLight2D = $Eyes
@onready var boar: CharacterBody2D = $"."
@onready var hurtbox_collision: CollisionShape2D = $HurtArea2D/HurtboxCollision
@onready var floor_detector_left: RayCast2D = $FloorDetectorLeft
@onready var floor_detector_right: RayCast2D = $FloorDetectorRight
@onready var attack_timer: Timer = $AttackTimer


var is_moving: bool
var is_stunned: bool = false
var direction = -1 #1 is facing right, -1 is facing left
var start_position: Vector2
var attacking: bool = false
var target_position: Vector2
var current_tween: Tween = null
var move_timer: float = 0.0
var follow_distance: int = 64

const SPEED = 2.8
const JUMP_VELOCITY = -200.0

func _ready() -> void:
	start_position = position

func _process(delta: float) -> void:
	detect_light(delta)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if is_stunned:
		return
	if not is_on_floor():
		velocity += get_gravity() * delta
	elif is_moving:
		sprite.play("walking")
	else: sprite.play("idle")

	if patrolling:
		is_moving = true
		patrol(delta)
	else:
		pass

	detect_wall()
	get_target(delta)
	move_and_slide()

func get_target(delta):
	if attacking or is_stunned or GameManager.in_light:
		return
	if vision.is_colliding():
		var collider = vision.get_collider()
		print(collider)
		print(collider.get_groups())
		if collider.is_in_group("player"):
			var hurtbox = collider.global_position
			target_position = hurtbox
			charge_player(delta)

func charge_player(delta):
	if attack_timer.time_left:
		return
	set_physics_process(false)
	attacking = true
	sprite.play("idle")
	if is_stunned:
		set_physics_process(true)
		return
	#play charge prep SFX
	await get_tree().create_timer(1.0).timeout
	sprite.play("run")
	if is_stunned:
		set_physics_process(true)
		return
	current_tween = create_tween()
	current_tween.tween_property(boar, "global_position", Vector2(target_position.x, boar.global_position.y), 0.5)
	if is_stunned:
		set_physics_process(true)
		return 
	await get_tree().create_timer(0.6).timeout
	sprite.play("idle")
	await get_tree().create_timer(1.0).timeout
	return_from_charge()


func detect_light(delta):
	if is_stunned:
		return
	if light_detector.is_colliding():
		var collider = light_detector.get_collider()
		print(collider)
		print(collider.get_groups())
		if collider.is_in_group("player"):
			return
		#elif collider.is_in_group("cone_area"):
			#if is_stunned:
				#return
			#stun()
			#await recover_from_stun()
			#return
		elif collider.is_in_group("light_area"):
			set_physics_process(false)
			stop_current_tween()
			sprite.play("idle")
			if not patrolling:
				vision.enabled = false
				await get_tree().create_timer(1.0).timeout
				return_to_position()
				attack_timer.start()
				await attack_timer.timeout
				vision.enabled = true
				attacking = false
			begin_following(delta)
			attacking = false

func begin_following(delta: float):
	if not patrolling:
		set_physics_process(true)
		return
	if is_stunned:
		return
	#1. Calculate distance from current position to player. This should be the same as the current distance to the light's edge.
	var player = get_tree().get_nodes_in_group("player")[0]
	var follow_distance = boar.global_position.distance_to(player.global_position)
	var last_player_pos = player.global_position
	var player_moving = false
	attacking = false
	#set_physics_process(false) # Disable physics processing to prevent conflicts

	while true:
		var current_player_pos = player.global_position
		var player_movement = current_player_pos - last_player_pos
		var distance_from_start = abs(boar.global_position.x - start_position.x)
		player_moving = player_movement.length() > 1.0  # Small threshold to detect movement

		#2. If player isn't moving, sprite.play("idle").
		if not player_moving:
			sprite.play("idle")
		#3. If player is moving, sprite.play("walking"), then move towards the same direction and distance as the player, staying on the x-axis.
		else:
			sprite.play("walking")
			var player_direction = player_movement.normalized()
			boar.global_position.x = player.global_position.x - follow_distance

		#4. If the player moves beyond patrol_distance, stop following, sprite.play("idle"), wait a moment, then return to the starting position.
		
		if distance_from_start >= patrol_distance or not floor_detector_left.is_colliding() or not floor_detector_right.is_colliding():
			sprite.play("idle")
			await get_tree().create_timer(1.0).timeout

			stop_current_tween()
			current_tween = create_tween()
			current_tween.tween_property(boar, "position", start_position, 1.0)
			await current_tween.finished
			set_physics_process(true)  # Re-enable physics when returning to normal
			break

		last_player_pos = current_player_pos
		await get_tree().process_frame

func detect_wall():
	if wall_detector.is_colliding():
		direction *= -1

func stun():
	if is_stunned:
		return
	is_stunned = true
	attacking = false
	stop_current_tween()
	boar.process_mode = Node.PROCESS_MODE_PAUSABLE
	set_physics_process(false)
	tusk.disabled = true
	sprite.play("hurt")
	print("stun")

func patrol(delta):
	if is_stunned:
		return
	if patrolling:
		sprite.play("walking")
		if patrol_time <= 0.0:
			return

		move_timer += delta
		while move_timer >= patrol_time:
			move_timer -= patrol_time
			direction *= -1

		var progress := move_timer / patrol_time
		if direction == 1:
			position.x = start_position.x + patrol_distance * progress
			sprite.flip_h = true
			body_lower.position.x = 1.0
			body_upper.position.x = 1.0
			light_detector.rotation_degrees = 180
			wall_detector.rotation_degrees = 180
			vision.rotation_degrees = 180
			tusk.position.x = 15.5
			eyes.position.x = 12.0
			hurtbox_collision.position.x = 15.75
		else:
			position.x = start_position.x + patrol_distance * (1.0 - progress)
			sprite.flip_h = false
			body_lower.position.x = -1.0
			body_upper.position.x = -1.0
			light_detector.rotation_degrees = 0
			wall_detector.rotation_degrees = 0
			vision.rotation_degrees = 0
			tusk.position.x = -15.5
			eyes.position.x = -12.0
			hurtbox_collision.position.x = -15.75
	else:
		return

func create_stun_timer():
	if is_stunned:
		return
	await get_tree().create_timer(stun_time).timeout

func stop_current_tween() -> void:
	if current_tween and current_tween.is_valid():
		current_tween.kill()
	current_tween = null

func recover_from_stun() -> void:
	await get_tree().create_timer(stun_time).timeout
	#sprite.play("walking")
	#return_to_position()
	#await get_tree().create_timer(stun_time).timeout
	set_physics_process(true)
	is_stunned = false
	tusk.disabled = false
	print("recover")

func return_to_position():
	stop_current_tween()
	sprite.play("walking")
	current_tween = create_tween()
	current_tween.tween_property(boar, "position", start_position, 1.0)
	await get_tree().create_timer(2.8).timeout
	sprite.play("idle")
	attacking = false
	set_physics_process(true)

func return_from_charge():
	stop_current_tween()
	sprite.play("walking")
	current_tween = create_tween()
	current_tween.tween_property(boar, "position", start_position, 1.0)
	await get_tree().create_timer(1.0).timeout
	sprite.play("idle")
	attacking = false
	set_physics_process(true)
