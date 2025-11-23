extends Node

var air: int = 100
var max_air: int = 100

func reset() -> void:
	air = max_air

func add_points(amount: int) -> void:
	air += amount
	if air >= max_air:
		air = max_air

func sub_points(amount: int) -> void:
	air -= amount
	if air <= 0:
		air = 0
