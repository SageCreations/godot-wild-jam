extends Area2D

@export var speed: int = 900

var _dir : int
func set_dir(d: int):
	_dir = d 
	
func _physics_process(delta: float) -> void:
	position += (transform.x * (_dir * speed)) * delta
	if _dir == 1:
		position.x += + Speed.get_speed()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Walls"):
		queue_free()


func _on_timer_timeout() -> void:
	queue_free()
