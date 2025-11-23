extends Node

const PLAYER_START_POSITION := Vector2i(448, 611)
const CAMERA_START_POSITION := Vector2i(576, 324)

@export var GameOver_Music: AudioStreamPlayer2D
@export var Level_Music: AudioStreamPlayer2D

@export var START_SPEED: float = 0.0
@export var MAX_SPEED: float = 7.0
var screen_size: Vector2i

var survival_accumilator_per_second: float = 10.0
var survival_accumilator: float = 0.0
@export var survival_accumilator_capacity: float = 1.0

var airFilter_accumilator_per_second: float = 10.0
var airFilter_accumilator: float = 0.0
@export var airFilter_accumilator_capacity: float = 50.0

var game_over: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	screen_size = get_window().size
	new_game()
	
func new_game() -> void:
	$Player.position = PLAYER_START_POSITION
	$Player.velocity = Vector2i(0, 0)
	$Camera2D.position = CAMERA_START_POSITION
	Speed.set_speed(START_SPEED)
	Score.reset()
	AirFilter.reset()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_over: 
		if Level_Music.playing == true:
			Level_Music.stop()
			GameOver_Music.play()
		return
	
	# score accumilator
	survival_accumilator += survival_accumilator_per_second * delta
	while survival_accumilator >= survival_accumilator_capacity:
		Score.add_points(1)
		survival_accumilator = 0.0
	
	# air filter decay
	airFilter_accumilator += airFilter_accumilator_per_second * delta
	while airFilter_accumilator >= airFilter_accumilator_capacity:
		AirFilter.sub_points(1)
		airFilter_accumilator = 0.0
	
	# Temporary, need to adjust speed by a modulus of the score, balance checks will be needed after enemies are added
	$Player.position.x += Speed.get_speed()
	$Camera2D.position.x += Speed.get_speed()
	

func _on_speed_increase_timeout() -> void:
	Speed.add_speed(0.1)
	if Speed.get_speed() >= MAX_SPEED:
		Speed.set_speed(MAX_SPEED)
