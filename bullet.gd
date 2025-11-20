extends Area2D


var _dir : int

func _on_body_entered(body: Node2D) -> void:
	body.free()
	
#func _physics_process(delta: float) -> void:
	#print_debug("Bullet _DIR : ",_dir)

func set_dir(d: int):
	_dir = d 
