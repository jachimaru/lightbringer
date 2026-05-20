extends Node2D

@export var next_level: PackedScene
@onready var bgm: AudioStreamPlayer = $BGM


# Called when the node enters the scene tree for the first time.
func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	GameManager.reset()
	GameManager.unpause_game.connect(unpause_game)
	GameManager.level_change.connect(change_level)
	await Transition.fade_from_black()

func _process(delta: float) -> void:
	if Input.is_action_pressed("pause"):
		GameManager.pause_game.emit()
	
	if GameManager.underground:
		bgm.volume_db = -24.0
		Hud.cave_bgm.playing = true
	else: 
		bgm.volume_db = -12.0
		if Hud.cave_bgm.playing:
			Hud.cave_bgm.playing = false
		else: return

func unpause_game():
	get_tree().paused = false

func change_level():
	if not next_level is PackedScene: return
	await Transition.fade_to_black()
	GameManager.reset()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)
