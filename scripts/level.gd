extends Node

const PLAYER_START_POSITION := Vector2i(448, 611)
const CAMERA_START_POSITION := Vector2i(576, 324)

var speed: float
const START_SPEED: float = 1.0
const MAX_SPEED: int = 25
var screen_size: Vector2i

var survival_accumilator_per_second: float = 10.0
var survival_accumilator: float = 0.0
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
	Score.reset()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_over: 
		return
	
	survival_accumilator += survival_accumilator_per_second * delta
	while survival_accumilator >= 1.0:
		Score.add_points(1)
		survival_accumilator = 0.0
	
	# Temporary, need to adjust speed by a modulus of the score, balance checks will be needed after enemies are added
	speed = START_SPEED
	
	$Player.position.x += speed
	$Camera2D.position.x += speed
	
	
	
