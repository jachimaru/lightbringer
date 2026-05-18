extends CenterContainer

@onready var settings_button: Button = %SettingsButton
@onready var close_button: Button = %CloseButton
@onready var exit_button: Button = %ExitButton
@onready var menu: NinePatchRect = %Menu
@onready var shard: Sprite2D = %FoundShard
@onready var shard_2: Sprite2D = %FoundShard2
@onready var shard_3: Sprite2D = %FoundShard3
@onready var shard_4: Sprite2D = %FoundShard4
@onready var shard_5: Sprite2D = %FoundShard5
@onready var shard_6: Sprite2D = %FoundShard6
@onready var shard_7: Sprite2D = %FoundShard7
@onready var shard_8: Sprite2D = %FoundShard8
@onready var shard_9: Sprite2D = %FoundShard9
@onready var shard_10: Sprite2D = %FoundShard10
@onready var shards = [shard, shard_2, shard_3, shard_4, shard_5, shard_6, shard_7, shard_8, shard_9, shard_10]
@onready var open_menu: AudioStreamPlayer = $OpenMenu
@onready var accept: AudioStreamPlayer = $Accept
@onready var decline: AudioStreamPlayer = $Decline

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.pause_game.connect(show_menu)
	GameManager.shards_changed.connect(update_shards)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") && menu.visible:
		decline.play()
		Transition.pause_vignette_off()
		menu.visible = false

func show_menu():
	menu.visible = true
	open_menu.play()
	Transition.pause_vignette_on()
	TextPopups.confirmation.visible = false
	get_tree().paused = true
	settings_button.grab_focus()

func _on_settings_button_pressed() -> void:
	pass # Replace with function body.

func _on_close_button_pressed() -> void:
	GameManager.unpause_game.emit()
	decline.play()
	menu.visible = false

func _on_exit_button_pressed() -> void:
	GameManager.quit_game = true
	TextPopups.confirmation.visible = true
	TextPopups.yes.grab_focus()
	#GameManager.confirm.emit()

func update_shards(): 
	var value = GameManager.moonshards - 1
	shards[value].visible = true
