extends Node

var air: int = 100

func reset() -> void:
	air = 100

func add_points(amount: int) -> void:
	air += amount

func sub_points(amount: int) -> void:
	air -= amount
	if air < 0:
		air = 0
