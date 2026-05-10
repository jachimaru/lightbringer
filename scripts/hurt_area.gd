class_name HurtArea2D extends Area2D

func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(hit_area: HitArea2D) -> void:
	if GameManager.damaged:
		return
	elif hit_area != null and owner.has_method("take_damage"):
		owner.take_damage()
		print(owner)
	elif hit_area != null and owner.has_method("stun"):
		owner.stun()
		await owner.recover_from_stun()
		print(owner)
	else:
		print("womp womp")
