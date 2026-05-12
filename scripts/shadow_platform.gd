extends AnimatableBody2D

@onready var sprites: Node2D = $Sprites
@onready var body_collision: CollisionShape2D = $Collision
@onready var light_detector: Area2D = $LightDetector
@onready var light_collision: CollisionShape2D = $LightDetector/LightCollision

var lit: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if lit:
		sprites.visible = false
		body_collision.disabled = true
	else:
		sprites.visible = true
		body_collision.disabled = false


func _on_light_detector_area_entered(area: Area2D) -> void:
	lit = true

func _on_light_detector_area_exited(area: Area2D) -> void:
	lit = false
