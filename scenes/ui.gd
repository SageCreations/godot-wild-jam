extends Control

@onready var _score_label = $Score
@onready var _ammo_count = $AmmoCount
@onready var _game_over_screen = $GameOver
@export var _player: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_game_over_screen.visible = false
	$GameOver/btn_retry.pressed.connect(restart_level)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_score_label.text = "Score: " + str(Score.score)
	_ammo_count.text = "Ammo Count: " + str(_player.ammo_count) + "/" + str(_player.max_ammo)
	
	if _player.state == _player.State.DEAD:
		_game_over_screen.visible = true
		$GameOver/Sore_label.text = "Score: " + str(Score.score)
		
func restart_level():
	get_tree().reload_current_scene()
