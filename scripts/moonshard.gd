extends Area2D

@onready var interact: Sprite2D = $Interact
@onready var moonshard_get: AudioStreamPlayer = $MoonshardGet

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
		moonshard_get.play()
		await moonshard_get.finished
		print("Moonshard collected!")
		GameManager.level_change.emit()
		GameManager.reset_flames.emit()
		get_tree().paused = true
