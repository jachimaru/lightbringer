extends Node2D

@onready var flame: AnimatedSprite2D = $Flame
@onready var interact: Sprite2D = %Interact
@onready var light_collision: CollisionShape2D = %LightCollision
@onready var light_fire: AudioStreamPlayer = $LightFire
@onready var firepit_flame: AudioStreamPlayer2D = $FirepitFlame


var lit = false
var player_inside = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.player_casting.connect(light_up)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if lit: firepit_flame.playing = true

func light_up():
	if not lit and player_inside:
		print("lighting")
		light_fire.play()
		flame.visible = true
		lit = true
		interact.visible = false
		light_collision.disabled = false
	else: return

func _on_firepit_area_body_entered(body: CharacterBody2D) -> void:
	if not lit && body.has_method("control_lantern"): 
		interact.visible = true
		GameManager.in_firepit = true
		player_inside = true

func _on_firepit_area_body_exited(body: CharacterBody2D) -> void:
	if not lit && body.has_method("control_lantern"): 
		interact.visible = false
		GameManager.in_firepit = false
		player_inside = false

func _on_lightwall_body_entered(body: CharacterBody2D) -> void:
	if body.has_method("control_lantern"):
		GameManager.in_light = true
		print(GameManager.in_light)


func _on_lightwall_body_exited(body: CharacterBody2D) -> void:
	if body.has_method("control_lantern"):
		GameManager.in_light = false
		print(GameManager.in_light)
