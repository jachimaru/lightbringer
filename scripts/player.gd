extends CharacterBody2D

@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var lantern_sprite: AnimatedSprite2D = $LanternSprite
@onready var lantern_light: PointLight2D = $LanternSprite/LanternLight
@onready var cone_light: PointLight2D = $LanternSprite/ConeLight
@onready var spell_collision: CollisionShape2D = $HitArea2D/SpellCollision
@onready var player_collision: CollisionShape2D = $PlayerCollision
@onready var starting_position = global_position

const SPEED = 100.0
const JUMP_VELOCITY = -200.0

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
		spell_collision.position.x = -7.0
		player_collision.position.x = -2.0
		var tween = create_tween()
		tween.tween_property(lantern_sprite, "position", Vector2(-11.0, -18.0), 0.3)
		cone_light.rotation_degrees = -165.0
	elif direction == 1:
		facing = 1
		player_sprite.flip_h = false
		spell_collision.position.x = 7.0
		player_collision.position.x = 2.0
		var tween = create_tween()
		tween.tween_property(lantern_sprite, "position", Vector2(11.0, -18.0), 0.3)
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
		tween.tween_property(lantern_sprite, "position", Vector2(x, 0.0), 0.3)
		
	if Input.is_action_just_released("lantern_down"):
		var tween = create_tween()
		var x = 11.0 * facing
		tween.tween_property(lantern_sprite, "position", Vector2(x, -18.0), 0.3)
		
	if Input.is_action_just_pressed("lantern_up"):
		var tween = create_tween()
		var x = 11.0 * facing
		tween.tween_property(lantern_sprite, "position", Vector2(x, -36.0), 0.3)

	if Input.is_action_just_released("lantern_up"):
		var tween = create_tween()
		var x = 11.0 * facing
		tween.tween_property(lantern_sprite, "position", Vector2(x, -18.0), 0.3)

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
	if GameManager.light > 1:
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
		cone_light.visible = true
		print("change to cone")
	else:
		light_mode = false
		lantern_light.visible = true
		cone_light.visible = false
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
	global_position = starting_position
	if GameManager.health <= 0: GameManager.game_over.emit()
