extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if GameManager.lantern_full == true: return
	if body.has_method("control_lantern"):
		GameManager.add_light.emit()
		GameManager.light += 1
		print(GameManager.light)
		queue_free()
