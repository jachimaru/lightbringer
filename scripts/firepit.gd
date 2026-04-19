extends Node2D

@onready var flame: AnimatedSprite2D = $Flame
@onready var interact: Sprite2D = %Interact
@onready var light_collision: CollisionShape2D = %LightCollision


var lit = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.player_casting.connect(light_up)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func light_up():
	if not lit:
		print("lighting")
		flame.visible = true
		lit = true
		interact.visible = false
		light_collision.disabled = false
	else: return

func _on_firepit_area_body_entered(body: CharacterBody2D) -> void:
	if not lit: 
		interact.visible = true
		GameManager.in_firepit = true

func _on_firepit_area_body_exited(body: CharacterBody2D) -> void:
	if not lit: 
		interact.visible = false
		GameManager.in_firepit = false
