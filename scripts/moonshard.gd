extends Area2D

@onready var interact: Sprite2D = $Interact

var player_in: bool

func _on_body_entered(body: CharacterBody2D) -> void:
	interact.visible = true
	player_in = true

func _on_body_exited(body: CharacterBody2D) -> void:
	interact.visible = false
	player_in = false

func _input(event: InputEvent) -> void:
	if player_in && Input.is_action_just_pressed("interact"):
		GameManager.moonshard.emit()
		print("Moonshard collected!")
		GameManager.level_change.emit()
		get_tree().paused = true
