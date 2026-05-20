extends Control

@onready var thanks: Label = $Thanks
@onready var sdg: Label = $SoliDeoGloria


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(3.0).timeout
	await Transition.fade_from_black()
	thanks.visible = true
	await get_tree().create_timer(2.0).timeout
	await Transition.fade_to_black()
	await get_tree().create_timer(2.0).timeout
	thanks.visible = false
	sdg.visible = true
	await Transition.fade_from_black()
	await get_tree().create_timer(3.0).timeout
	await Transition.fade_to_black()
	GameManager.game_over.emit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
