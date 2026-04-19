extends CenterContainer

@onready var start_game: Button = %StartGame
@onready var quit: Button = %Quit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_game.grab_focus()


func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
