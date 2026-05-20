extends Control

@export var bg_color : Color = Color.BLACK
@export var to_scene : PackedScene = null
@export var title_color := Color.BLUE_VIOLET
@export var text_color := Color.WHITE
@export var title_font : FontFile = null
@export var text_font : FontFile = null
@export var Music : AudioStream = null
@export var Use_Video_Audio : bool = false
@export var Video : VideoStream = null

const section_time := 2.0
const line_time := 0.8
const base_speed := 30
const speed_up_multiplier := 10.0

var scroll_speed : float = base_speed
var speed_up := false

@onready var colorrect := $ColorRect
@onready var videoplayer := $VideoPlayer
@onready var line := $CreditsContainer/Line
var started := false
var finished := false

var section
var section_next := true
var section_timer := 0.0
var line_timer := 0.0
var curr_line := 0
var lines := []
var stream_player

var credits = [
	[
		"A Game by Jinho Yun"
	],[
		"Programming",
		"Jinho Yun",
		"GodotCredits - Ben Bishop"
	],[
		"Art",
		"Player Sprite - LuckyLoops",
		"Firepit and firepit flame - Asymmetric",
		"Input Buttons - greenpixels_",
		"Enemy Sprites - Anokolisa",
		"SunnyLand Tall Forest, Gothicvania Rocky Pass,",
		"and Thorn Sprite - ansimuz",
		"DarkForest Tileset and Background- Ulianeya",
		"Stone&Moon Background - Forest_Elfs",
		"Cave Background - Admurin (admurin.itch.io)",
		"Menu Backgrounds, Buttons, and Moonshard Sprite - Jinho Yun"
	],[
		"Font",
		"BitPotion - Joeb Rogers",
	],[
		"Music",
		"End Credits - Piano 6 (Piano Ambient Music Vol. 2) - AlkaKrab",
		"Start Screen - The Otherside (Ancient Horrors) - Atelier Magicae",
		"Level One - The Black Mirror (Ancient Horrors) - Atelier Magicae",
		"Level Two - Cinder and Rot (Ancient Horrors) - Atelier Magicae",
		"Level Three - Cinderfall (Ancient Horrors) - Atelier Magicae",
		"Level Four - Go Down (Ancient Horrors) - Atelier Magicae",
		"Level Five - Shudder (Ancient Horrors) - Atelier Magicae",
		"Level Six - It's Following (Ancient Horrors) - Atelier Magicae"
	],[
		"Sound Effects",
		"Enemy, UI, and Item Collection SFX - Atelier Magicae",
		"Walking, Cave, and Fire SFX - Nox_Sound_Design",
		"Jumping SFX - Chequered Ink"
	#],[
		#"Testers",
		#"My Wife",
		#"Name 2",
		#"Name 3"
	],[
		"Tools Used",
		"Developed with Godot Engine",
		"https://godotengine.org/license",
		"",
		"My Art created with Aseprite and edited with GIMP",
		"https://www.aseprite.org/",
		"https://www.gimp.org/"
	],[
		"Special Thanks",
		"My Wife",
		"CJ",
		"",
		"Most Importantly:",
		"My Savior, Jesus, who died for my sins",
		"so I could be forgiven and free", 
		"to love and serve Him."
	]
]

func _ready():
	await Transition.fade_from_black()
	colorrect.color = bg_color
	videoplayer.set_stream(Video)
	if !Use_Video_Audio:
		var stream = AudioStreamPlayer.new()
		stream_player = stream
		stream.set_stream(Music)
		add_child(stream)
		videoplayer.set_volume_db(-80)
		stream.play()
	else:
		videoplayer.set_volume_db(0)
	videoplayer.play()
	

func _process(delta):
	scroll_speed = base_speed * delta
	
	if section_next:
		section_timer += delta * speed_up_multiplier if speed_up else delta
		if section_timer >= section_time:
			section_timer -= section_time
			
			if credits.size() > 0:
				started = true
				section = credits.pop_front()
				curr_line = 0
				add_line()
	
	else:
		line_timer += delta * speed_up_multiplier if speed_up else delta
		if line_timer >= line_time:
			line_timer -= line_time
			add_line()
	
	if speed_up:
		scroll_speed *= speed_up_multiplier
	
	if lines.size() > 0:
		for l in lines:
			l.set_global_position(l.get_global_position() - Vector2(0, scroll_speed))
			if l.get_global_position().y < l.get_line_height():
				lines.erase(l)
				l.queue_free()
	elif started:
		finish()


func finish():
	if not finished:
		finished = true
		if to_scene != null:
			var path = to_scene.get_path()
			#var stream = AudioStreamPlayer.new()
			var tween = create_tween()
			tween.tween_property(stream_player, "volume_db", -80.0, 3.0)
			await get_tree().create_timer(1.8).timeout
			await Transition.fade_to_black()
			get_tree().change_scene_to_file(path)
		else:
			get_tree().quit()


func add_line():
	var new_line = line.duplicate()
	new_line.text = section.pop_front()
	lines.append(new_line)
	if curr_line == 0:
		if title_font != null:
			new_line.set("theme_override_fonts/font", title_font)
		new_line.set("theme_override_colors/font_color", title_color)
	
	else:
		if text_font != null:
			new_line.set("theme_override_fonts/font", text_font)
		new_line.set("theme_override_colors/font_color", text_color)
	
	$CreditsContainer.add_child(new_line)
	
	if section.size() > 0:
		curr_line += 1
		section_next = false
	else:
		section_next = true


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		finish()
	if event.is_action_pressed("ui_down") and !event.is_echo():
		speed_up = true
	if event.is_action_released("ui_down") and !event.is_echo():
		speed_up = false
