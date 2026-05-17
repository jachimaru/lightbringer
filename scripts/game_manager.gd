extends Node

var health: int = 3
var light: int
var lantern_cone: bool = false
var has_glide: bool = false
var has_double_jump: bool = false
var has_wall_climb: bool = false
var lantern_full: bool = false
var sign_move = false
var sign_jump = false
var sign_lantern = false
var sign_lantern_light = false
var last_popup: String = "none"
var in_collision: bool
var in_firepit: bool
var quit_game: bool
var in_light: bool
var moonshards: int
var damaged: bool
var gameover: bool

@warning_ignore("unused_signal")
signal add_light
@warning_ignore("unused_signal")
signal remove_light
@warning_ignore("unused_signal")
signal player_interact
@warning_ignore("unused_signal")
signal player_casting
@warning_ignore("unused_signal")
signal health_changed
signal game_over
@warning_ignore("unused_signal")
signal deal_damage
@warning_ignore("unused_signal")
signal show_popup
@warning_ignore("unused_signal")
signal hide_popup
@warning_ignore("unused_signal")
signal waiting_input
@warning_ignore("unused_signal")
signal tooltip_collision_entered
@warning_ignore("unused_signal")
signal tooltip_collision_exited
@warning_ignore("unused_signal")
signal pause_game
@warning_ignore("unused_signal")
signal unpause_game
@warning_ignore("unused_signal")
signal light_flame
@warning_ignore("unused_signal")
signal confirm
signal moonshard
signal shards_changed
@warning_ignore("unused_signal")
signal level_change
signal reset_flames


func _ready() -> void:
	game_over.connect(func(): call_deferred("_gameover"))
	moonshard.connect(update_moonshards)

func _gameover():
	print("you died")
	health = 3
	light = 1
	lantern_full = false
	gameover = false
	Hud.reset()
	get_tree().change_scene_to_file("res://scenes/start_menu.tscn")

func reset():
	light = 1
	lantern_full = false

func pause():
	get_tree().paused = true

func stop_movement():
	get_tree().paused = true

func update_moonshards():
	moonshards += 1
	shards_changed.emit()
	print(moonshards)
