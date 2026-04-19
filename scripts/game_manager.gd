extends Node

var health: int
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

signal add_light
signal remove_light
signal player_interact
signal player_casting
signal health_changed
signal game_over
signal deal_damage
signal show_popup
signal hide_popup
signal waiting_input
signal tooltip_collision_entered
signal tooltip_collision_exited
signal pause_game
signal unpause_game
signal light_flame
signal confirm

func _ready() -> void:
	game_over.connect(func(): call_deferred("_gameover"))
	health = 3
	light = 1

func _gameover():
	print("you died")
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func reset():
	health = 3
	light = 1

func pause():
	get_tree().paused = true

func stop_movement():
	get_tree().paused = true
