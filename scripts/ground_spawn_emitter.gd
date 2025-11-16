extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("Player entered")
		SignalBus.Ground_Needed.emit()
