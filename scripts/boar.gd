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



var is_stunned: bool = false
var direction = -1 #1 is facing right, -1 is facing left
var start_position: Vector2
var attacking: bool = false
var target_position: Vector2
var current_tween: Tween = null
var move_timer: float = 0.0

const SPEED = 100.0
const JUMP_VELOCITY = -200.0

func _ready() -> void:
	start_position = position

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		sprite.play("idle")
	if patrolling:
		patrol(patrol_distance, delta)
	else:
		pass
	move_and_slide()

func get_target(delta):
	if attacking or is_stunned or GameManager.in_light:
		return
	if vision.is_colliding():
		var collider = vision.get_collider()
		if collider.is_in_group("player"):
			var hurtbox = collider.global_position
			target_position = hurtbox
			charge_player(delta)

func charge_player(delta):
	pass

func detect_light():
	pass

func detect_wall():
	pass

func stun_boar(stun_time):
	pass

func patrol(patrol_distance, delta):
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
	else:
		return

func create_stun_timer(stun_time):
	await get_tree().create_timer(stun_time).timeout

func stop_current_tween() -> void:
	if current_tween and current_tween.is_valid():
		current_tween.kill()
	current_tween = null
