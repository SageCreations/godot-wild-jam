extends Node

var score: int = 0

func reset() -> void:
	score = 0

func add_points(amount: int) -> void:
	score += amount

func sub_points(amount: int) -> void:
	score -= amount
	if score < 0:
		score = 0
