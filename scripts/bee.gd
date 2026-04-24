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

func _ready() -> void:
	start_position = position

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		sprite.play("idle")
	if attacking:
		sprite.play("attack")
	detect_light(delta)
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
	var collider = light_detector.get_collider(delta)
	if light_detector.is_colliding():
		if collider.is_in_group("light_area"):
			set_physics_process(false)
			stinger_collision.disabled = true
			await get_tree().create_timer(2.0).timeout
			set_physics_process(true)
			return_to_position(delta)
		if collider.is_in_group("cone_area"):
			take_damage()


func handle_attack():
	var attacking_position: Vector2
	attacking = true
	attacking_position = position
	 #move toward target_position, move back to attacking_position

func get_target():
	pass #if attack_ray_cast is colliding and collider is in group "player", set target_position to Player's hurtarea2d hitbox.

func take_damage():
	pass #stun and disable hit and hurt box collisions for 2 seconds.

func return_to_position(delta):
	var tween = create_tween()
	tween.tween_property(bee, "position", start_position, 1.0)
