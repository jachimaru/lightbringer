extends CharacterBody2D

@export var move_distance: float
@export var move_time: float


const SPEED = 100.0
const JUMP_VELOCITY = -400.0

@onready var body_collision_1: CollisionShape2D = $BodyCollision1
@onready var body_collision_2: CollisionShape2D = $HurtArea2D/BodyCollision2
@onready var stinger_collision: CollisionShape2D = $HitArea2D/StingerCollision
@onready var attack_ray_cast: ShapeCast2D = %AttackRayCast
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var light_detector: ShapeCast2D = $LightDetector
@onready var bee: CharacterBody2D = $"."
@onready var timer: Timer = $Timer
@onready var hurt_area: HurtArea2D = $HurtArea2D
@onready var hurt_timer: Timer = $HurtTimer
@onready var hit_area_2d: HitArea2D = $HitArea2D


var detection_array: PackedVector2Array = PackedVector2Array([
	Vector2 (10.0, 100.0),
	Vector2 (-75.0, 100.0),
	Vector2 (0.0, 0.0),
	])
var flipped_array: PackedVector2Array = PackedVector2Array([
	Vector2 (-10.0, 100.0),
	Vector2 (75.0, 100.0),
	Vector2 (0.0, 0.0),
	])
var direction = 1
var start_position: Vector2
var move_timer: float = 0.0
var attacking: bool = false
var target_position: Vector2
var is_stunned: bool = false
var current_tween: Tween = null

func _ready() -> void:
	start_position = position

func _process(delta: float) -> void:
	detect_light(delta)

func _physics_process(delta: float) -> void:
	if is_stunned or attacking:
		return
	if not is_on_floor():
		sprite.play("idle")
	get_target(delta)
	set_move_route(delta)

func set_move_route(delta: float) -> void:
	if move_time <= 0.0:
		return

	move_timer += delta
	while move_timer >= move_time:
		move_timer -= move_time
		direction *= -1

	var progress := move_timer / move_time
	if direction == 1:
		position.x = start_position.x + move_distance * progress
		sprite.flip_h = true
		body_collision_1.position.x = 3.0
		body_collision_2.position.x = -2.0
		stinger_collision.position.x = 8.0
		attack_ray_cast.shape.points = flipped_array
	else:
		position.x = start_position.x + move_distance * (1.0 - progress)
		sprite.flip_h = false
		body_collision_1.position.x = -3.0
		body_collision_2.position.x = 2.0
		stinger_collision.position.x = -8.0
		attack_ray_cast.shape.points = detection_array

func detect_light(delta):
	if light_detector.is_colliding():
		var collider = light_detector.get_collider(0)
		if collider.is_in_group("light_area"):
			if is_stunned:
				return
			stun_bee()
			await recover_from_stun()
			return
		#if collider.is_in_group("cone_area"):
			#take_damage()

func handle_attack(delta):
	set_physics_process(false)
	var attacking_position: Vector2
	attacking = true
	hit_area_2d.monitorable = true
	stinger_collision.disabled = false
	sprite.play("attack")
	attacking_position = position
	print("from: ", attacking_position, " to ", target_position)
	attack_ray_cast.enabled = false
	body_collision_1.disabled = true
	stop_current_tween()
	current_tween = create_tween()
	current_tween.tween_property(bee, "position", target_position, 1.0)
	print(is_stunned)
	if is_stunned:
		return
	print("moving to: ", target_position)
	bee.process_mode = Node.PROCESS_MODE_DISABLED
	await wait_seconds(1.0)
	if is_stunned:
		return
	bee.process_mode = Node.PROCESS_MODE_PAUSABLE
	stop_current_tween()
	current_tween = create_tween()
	current_tween.tween_property(bee, "position", attacking_position, 1.0)
	print(is_stunned)
	if is_stunned:
		return
	print("moving to: ", attacking_position)
	await wait_seconds(1.0)
	if is_stunned:
		return
	body_collision_1.disabled = false
	stinger_collision.disabled = true
	await wait_seconds(1.0)
	attacking = false
	attack_ray_cast.enabled = true
	hit_area_2d.monitorable = false
	set_physics_process(true)
	 #move toward target_position, move back to attacking_position

func get_target(delta):
	if attacking or is_stunned:
		return
	if attack_ray_cast.is_colliding():
		var collider = attack_ray_cast.get_collider(0)
		if collider.is_in_group("player"):
			var hurtbox = collider.global_position
			target_position = hurtbox
			handle_attack(delta)

func take_damage():
	hurt_area.monitoring = false
	hit_area_2d.monitorable = false
	set_physics_process(false)
	sprite.play("hurt")
	hurt_timer.start()
	await hurt_timer.timeout
	set_physics_process(true)
	hurt_area.monitoring = true

func stop_current_tween() -> void:
	if current_tween and current_tween.is_valid():
		current_tween.kill()
	current_tween = null

func wait_seconds(duration: float) -> void:
	var elapsed := 0.0
	while elapsed < duration:
		if is_stunned:
			return
		elapsed += await get_tree().process_frame

func stun_bee() -> void:
	if is_stunned:
		return
	is_stunned = true
	attacking = false
	stop_current_tween()
	bee.process_mode = Node.PROCESS_MODE_PAUSABLE
	set_physics_process(false)
	attack_ray_cast.enabled = false
	hit_area_2d.monitorable = false
	stinger_collision.disabled = true
	sprite.play("hurt")

func recover_from_stun() -> void:
	await get_tree().create_timer(2.0).timeout
	return_to_position()
	await get_tree().create_timer(1.0).timeout
	is_stunned = false
	set_physics_process(true)

func return_to_position():
	stop_current_tween()
	current_tween = create_tween()
	current_tween.tween_property(bee, "position", start_position, 1.0)
