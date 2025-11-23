extends Node

var _speed: float = 0.1

func get_speed() -> float:
	return _speed

func set_speed(s: float):
	_speed = s

func add_speed(s: float):
	_speed += s
