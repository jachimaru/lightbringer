extends Area2D

@export var sign_text: String

@onready var interact: Sprite2D = $Interact

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#if Input.is_action_just_pressed("interact") && GameManager.in_collision:
		#GameManager.show_popup.emit()
		#GameManager.in_collision = false
	pass


func _on_body_entered(body: CharacterBody2D) -> void:
	if body.name == "Player":
		body.current_sign = self
	TextPopups.sign_label.text = sign_text
	print(sign_text)
	print(TextPopups.sign_label.text)
	interact.visible = true
	GameManager.in_collision = true
	#GameManager.tooltip_collision_entered.emit()
	#print("enter")

func _on_body_exited(body: CharacterBody2D) -> void:
	if body.name == "Player":
		if body.current_sign == self:
			body.current_sign = null
	interact.visible = false
	GameManager.in_collision = false
	#GameManager.tooltip_collision_exited.emit()
	#print("exit")
