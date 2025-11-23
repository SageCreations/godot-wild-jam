extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		SignalBus.Ground_Needed.emit()
		queue_free()
