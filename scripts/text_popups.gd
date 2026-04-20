extends CanvasLayer

@onready var sign_label: Label = %SignLabel
@onready var popup_container: CenterContainer = %PopupContainer
@onready var confirmation: Control = %Confirmation
@onready var signs: Control = %Signs
@onready var yes: Button = %Yes
@onready var no: Button = %No

var showing_popup = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.show_popup.connect(_show_popup)
	GameManager.hide_popup.connect(_hide_popup)
	#GameManager.confirm.connect(show_confirm)

func _show_popup():
	signs.visible = true
	print("Sign Text: ", sign_label.text)
	get_tree().paused = true
	#await GameManager.waiting_input
	#GameManager.hide_popup.emit()
	#GameManager.in_collision = false

func _hide_popup():
	signs.visible = false

func _input(event):
	if event.is_action_pressed("interact"): # Or any custom input action
		GameManager.waiting_input.emit()
		confirmation.visible = false
		get_tree().paused = false

#func show_confirm():
	#confirmation.visible = true
	#yes.grab_focus()

func _on_yes_pressed() -> void:
	if GameManager.quit_game:
		get_tree().quit()

func _on_no_pressed() -> void:
	if GameManager.quit_game:
		GameManager.quit_game = false
		GameManager.pause_game.emit()
