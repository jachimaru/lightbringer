extends CanvasLayer

@onready var flame_count_label: Label = %FlameCountLabel
@onready var health_0: TextureRect = %Health0
@onready var health_1: TextureRect = %Health1
@onready var health_2: TextureRect = %Health2
@onready var hud: CanvasLayer = $"."


var flame_count = 0

func _process(delta: float) -> void:
	update_count()

func _ready() -> void:
	GameManager.add_light.connect(_add_light)
	GameManager.remove_light.connect(_remove_light)
	GameManager.health_changed.connect(_update_health)
	GameManager.reset_flames.connect(reset)
	#update_count()

func _add_light():
	flame_count += 1

func _remove_light():
	flame_count -= 1

func update_count():
	flame_count_label.text = str(flame_count)
	if flame_count == 10:
		flame_count_label.label_settings.font_color = Color.CRIMSON
	else: flame_count_label.label_settings.font_color = Color.WHITE

func _update_health():
	if GameManager.health == 2: health_2.visible = false
	elif GameManager.health == 1: health_1.visible = false
	elif GameManager.health == 0: health_0.visible = false

func reset():
	flame_count == 0
	flame_count_label.text = str(flame_count)
	print("resetting")
