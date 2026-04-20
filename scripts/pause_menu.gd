extends CenterContainer

@onready var settings_button: Button = %SettingsButton
@onready var close_button: Button = %CloseButton
@onready var exit_button: Button = %ExitButton
@onready var menu: NinePatchRect = %Menu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.pause_game.connect(show_menu)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		menu.visible = false

func show_menu():
	menu.visible = true
	TextPopups.confirmation.visible = false
	get_tree().paused = true
	settings_button.grab_focus()

func _on_settings_button_pressed() -> void:
	pass # Replace with function body.

func _on_close_button_pressed() -> void:
	GameManager.unpause_game.emit()
	menu.visible = false

func _on_exit_button_pressed() -> void:
	GameManager.quit_game = true
	TextPopups.confirmation.visible = true
	TextPopups.yes.grab_focus()
	#GameManager.confirm.emit()
