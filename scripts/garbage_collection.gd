extends Node


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		var player: Node2D = body
		player.state = player.State.DEAD
	else:
		body.queue_free()
