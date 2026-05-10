extends CharacterBody2D

@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var lantern_sprite: AnimatedSprite2D = $LanternSprite
@onready var lantern_light: PointLight2D = $LanternSprite/LanternLight
@onready var cone_light: PointLight2D = $LanternSprite/ConeLight
@onready var spell_collision: CollisionShape2D = %SpellCollision
@onready var hit_area_2d: HitArea2D = %HitArea2D
@onready var player_collision: CollisionShape2D = $PlayerCollision
@onready var starting_position = global_position
@onready var radius_collider: CollisionShape2D = %RadiusCollider
@onready var cone_collider: CollisionShape2D = %ConeCollider
@onready var hurt_area_2d: HurtArea2D = $HurtArea2D
@onready var cooldown_timer: Timer = %CooldownTimer
@onready var player: CharacterBody2D = $"."
@onready var hurt_area_collision: CollisionShape2D = $HurtArea2D/HurtAreaCollision
@onready var cone_area: Area2D = $LanternSprite/ConeLight/ConeArea

const SPEED = 120.0
const JUMP_VELOCITY = -250.0

var direction := Input.get_axis("move_left", "move_right")
var facing = 1
var light_mode = GameManager.lantern_cone #true = cone, false = radius
var playing_animation: bool
var stop_input = false
var current_sign = null


func _ready() -> void:
	GameManager.add_light.connect(_add_light)
	GameManager.remove_light.connect(_remove_light)
	GameManager.deal_damage.connect(take_damage)
	GameManager.light_flame.connect(handle_lighting)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and current_sign and GameManager.in_collision:
		TextPopups._show_popup()
		await GameManager.waiting_input
		GameManager.hide_popup.emit()
		GameManager.in_collision = false
	if Input.is_action_just_pressed("use_flame") and GameManager.in_firepit:
		handle_lighting()
	add_gravity(delta)
	if Input.is_action_just_pressed("lantern_change"): _toggle_lantern()
	handle_interact()
	control_lantern()
	handle_jump()
	handle_move()
	flip_sprite()
	handle_animations()
	move_and_slide()

func flip_sprite():
	if direction == -1:
		facing = -1
		player_sprite.flip_h = true
		player_collision.position.x = -2.0
		var tween = create_tween()
		tween.tween_property(lantern_sprite, "position", Vector2(-11.0, -8.0), 0.3)
		cone_light.rotation_degrees = -165.0
	elif direction == 1:
		facing = 1
		player_sprite.flip_h = false
		player_collision.position.x = 2.0
		var tween = create_tween()
		tween.tween_property(lantern_sprite, "position", Vector2(11.0, -8.0), 0.3)
		cone_light.rotation_degrees = 15.0

func handle_move():
	if Input.is_action_pressed("move_left"):
		direction = -1
		velocity.x = direction * SPEED
	elif Input.is_action_pressed("move_right"):
		direction = 1
		velocity.x = direction * SPEED
	else:
		direction = 0
		velocity.x = move_toward(velocity.x, 0, SPEED)

func handle_jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func add_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

func control_lantern():
	if Input.is_action_just_pressed("lantern_down"):
		var tween = create_tween()
		var x = 11.0 * facing
		tween.tween_property(lantern_sprite, "position", Vector2(x, 10.0), 0.3)
		
	if Input.is_action_just_released("lantern_down"):
		var tween = create_tween()
		var x = 11.0 * facing
		tween.tween_property(lantern_sprite, "position", Vector2(x, -8.0), 0.3)
		
	if Input.is_action_just_pressed("lantern_up"):
		var tween = create_tween()
		var x = 11.0 * facing
		tween.tween_property(lantern_sprite, "position", Vector2(x, -26.0), 0.3)

	if Input.is_action_just_released("lantern_up"):
		var tween = create_tween()
		var x = 11.0 * facing
		tween.tween_property(lantern_sprite, "position", Vector2(x, -8.0), 0.3)

func _add_light():
	var add_light_scale = lantern_light.scale * Vector2(1.2, 1.2)
	var add_cone_scale = cone_light.scale * Vector2(1.1, 1.1)
	if GameManager.light < 10:
		var tween = create_tween()
		tween.tween_property(lantern_light, "scale", add_light_scale, 0.5)
		tween.tween_property(cone_light, "scale", add_cone_scale, 0.5)
	elif GameManager.light == 10:
		var tween = create_tween()
		tween.tween_property(lantern_light, "scale", add_light_scale, 0.5)
		tween.tween_property(cone_light, "scale", add_cone_scale, 0.5)
		GameManager.lantern_full = true
	else: 
		print("Can't increase Light")

func _remove_light():
	var sub_light_scale = lantern_light.scale * Vector2(0.8, 0.8)
	var sub_cone_scale = cone_light.scale * Vector2(0.9, 0.9)
	if GameManager.light == 11:
		var tween = create_tween()
		tween.tween_property(lantern_light, "scale", sub_light_scale, 0.5)
		tween.tween_property(cone_light, "scale", sub_cone_scale, 0.5)
		print(GameManager.light)
		GameManager.lantern_full = false
	elif GameManager.light > 1:
		var tween = create_tween()
		tween.tween_property(lantern_light, "scale", sub_light_scale, 0.5)
		tween.tween_property(cone_light, "scale", sub_cone_scale, 0.5)
		print(GameManager.light)
		GameManager.lantern_full = false
	else: print("Can't decrease Light")

#switches lantern mode from radius to cone, if GameManager.lantern_cone = true
func _toggle_lantern():
	if light_mode != true:
		light_mode = true
		lantern_light.visible = false
		radius_collider.disabled = true
		cone_light.visible = true
		hit_area_2d.visible = true
		spell_collision.visible = true
		cone_collider.visible = false
		cone_area.visible = false
		spell_collision.disabled = false
		hit_area_2d.monitorable = true
		cooldown_timer.start()
		await cooldown_timer.timeout
		hit_area_2d.visible = false
		spell_collision.visible = false
		cone_collider.visible = true
		cone_area.visible = true
		spell_collision.disabled = true
		hit_area_2d.monitorable = false
		cone_collider.disabled = false

	else:
		light_mode = false
		lantern_light.visible = true
		radius_collider.disabled = false
		cone_light.visible = false
		cone_collider.disabled = true
		print("change to radius")

func handle_interact():
	if Input.is_action_just_pressed("interact"):
		GameManager.player_interact.emit()
		print("Interacting")

func handle_lighting():
	if GameManager.light > 1:
		playing_animation = true
		spell_collision.disabled = false
		#stop_input = true
		GameManager.player_casting.emit()
		player_sprite.play("use_flame")
		await get_tree().create_timer(0.5).timeout
		GameManager.in_firepit = false
		playing_animation = false
		spell_collision.disabled = true
		print("Used light")
		GameManager.light -= 1
		print(GameManager.light)
		GameManager.remove_light.emit()
		#stop_input = false
	if GameManager.light <= 1: print("No light available")

func handle_animations():
	if is_on_floor():
		if direction != 0 && not playing_animation:
			player_sprite.play("run")
		if Input.is_action_just_released("move_left") or Input.is_action_just_released("move_right"):
			playing_animation = true
			player_sprite.play("stop")
			await player_sprite.animation_finished
			playing_animation = false
		if direction == 0 && not playing_animation: player_sprite.play("idle")
	else:
		player_sprite.play("jump")

func take_damage():
	GameManager.health -= 1
	GameManager.health_changed.emit()
	GameManager.damaged = true
	player_collision.disabled = true
	player.set_collision_mask_value(1, false)
	player_sprite.flip_v = true
	hurt_area_2d.monitoring = false
	hurt_area_collision.disabled = true
	velocity.y = JUMP_VELOCITY * 0.5
	Engine.time_scale = 0.25
	await Transition.fade_to_black()
	Engine.time_scale = 1
	GameManager.damaged = false
	hurt_area_2d.monitoring = true
	hurt_area_collision.disabled = false
	player.set_collision_mask_value(1, true)
	player_collision.disabled = false
	player_sprite.flip_v = false
	global_position = starting_position
	if GameManager.health <= 0: GameManager.game_over.emit()
	await Transition.fade_from_black()
