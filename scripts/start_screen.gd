extends CenterContainer

@onready var start_game: Button = %StartGame
@onready var quit: Button = %Quit
@onready var start_sfx: AudioStreamPlayer2D = $StartGame
@onready var main_menu: AudioStreamPlayer2D = $MainMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Hud.hud.visible = false
	await Transition.fade_from_black()
	start_game.grab_focus()


func _on_start_game_pressed() -> void:
	main_menu.playing = false
	start_sfx.play()
	Transition.fade_to_black()
	#await start_sfx.finished
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://scenes/levelone.tscn")
	Transition.fade_from_black()
	Hud.hud.visible = true


func _on_quit_pressed() -> void:
	get_tree().quit()
