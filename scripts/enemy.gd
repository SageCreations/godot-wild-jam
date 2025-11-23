extends CharacterBody2D

# exported variables
@export var pts_awarded: int = 10
@export var health: int = 3
@export var speed: float = 120.0
@export var gravity: float = 1200.0
@export var jump_velocity: float = -600.0
var _should_jump: bool = false
var _dead: bool = false
var rand: int

@export var powerup_drops: Array[PackedScene]

# interal ref of player for its location and a setter function to set in spawner script
var _player: Node2D = null

func set_player(p: Node2D):
	_player = p

# ref to child nodes of the enemy
@onready var floor_ahead: RayCast2D = $FloorAhead
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# State handling for enemy
enum State {
	IDLE,
	RUN,
	JUMP,
	FALL,
	ATTACK,
	DEAD,
	HIT,
}
var state: State = State.RUN
var facing_direction: int = 1 # 1 is right, -1 is left


func _logic_idle(_delta: float) -> void:
	velocity.x = 0.0


func _logic_run(_delta: float) -> void:
	var dx: float = _player.global_position.x - global_position.x
	var dir: float = sign(dx)
		
	if dir == 0.0:
		dir = 0.0
	
	if dir == 1.0:
		position.x += Speed.get_speed() + 0.2

	if (global_position.x > _player.global_position.x - 50) and (global_position.x < _player.global_position.x + 50):
		velocity.x = 0
	else:
		velocity.x = dir * speed
	
	var ahead_offset_x: float = 20.0 * dir
	floor_ahead.target_position = Vector2(ahead_offset_x, 52.0)
	if not floor_ahead.is_colliding():
		_should_jump = true


func _logic_jump(_delta: float) -> void:
	velocity.y = jump_velocity
	velocity.x += (-facing_direction * jump_velocity) / 2
	_should_jump = false


func _logic_fall(_delta: float) -> void:
	pass


func _logic_attack(_delta: float) -> void:
	velocity.x = 0
	await anim.animation_finished
	state = State.RUN
	if _player.is_hurt == false:
		_player._player_hit()


func _logic_dead(_delta: float) -> void:
	velocity.x = 0
	await anim.animation_finished
	if _dead == false:
		if rand >= 65:
			var new_power_up_scene = powerup_drops.pick_random()
			var power_up = new_power_up_scene.instantiate()
			get_parent().add_child(power_up)
			power_up.global_position = global_position
		_dead = true
	
	if _player.double_points == true:
		#print("double points awarded")
		Score.add_points(pts_awarded*2)
	else:
		Score.add_points(pts_awarded)
	queue_free()


func _logic_hit(_delta: float) -> void:
	velocity.x = 0
	await anim.animation_finished
	state = State.RUN
	


func _sub_health(amount: int) -> void:
	health -= amount
	$Attack_Sound.pitch_scale = 4.0
	$Attack_Sound.play()
	if health <= 0:
		$Attack_Sound.pitch_scale = 0.5
		$Attack_Sound.play()
		state = State.DEAD


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(powerup_drops.size() > 0, "needs items to drop at random")
	rand = randi()%100


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


func _update_state() -> void:
	if state == State.DEAD:
		return
	
	if state == State.HIT:
		return
	
	if state == State.ATTACK:
		return
	
	if (global_position.x > _player.global_position.x - 50) and (global_position.x < _player.global_position.x + 50):
		if _player.is_on_floor() and _player.is_hurt == false:
			state = State.ATTACK
			$Attack_Sound.play()
			return
	
	if not is_on_floor():
		state = State.FALL
		return  # ground stuff isnt needed if in the air
	
	if _should_jump:
		state = State.JUMP
		return
		
	state = State.RUN


func _update_direction() -> void:
	if abs(velocity.x) > 0.1:
		var new_dir: int = sign(velocity.x)
		
		if new_dir != 0 and new_dir != facing_direction:
			facing_direction = new_dir
			anim.flip_h = (facing_direction < 0)


func _apply_state_logic(delta: float) -> void:
	match state:
		State.IDLE:
			_logic_idle(delta)
		State.RUN:
			_logic_run(delta)
		State.JUMP:
			_logic_jump(delta)
		State.FALL:
			_logic_fall(delta)
		State.ATTACK:
			_logic_attack(delta)
		State.DEAD:
			_logic_dead(delta)
		State.HIT:
			_logic_hit(delta)


func _update_animation() -> void:
	var target_anim: String = ""
	
	match state:
		State.IDLE:
			target_anim = "idle"
		State.RUN:
			target_anim = "run"
		State.JUMP:
			target_anim = "jump"
		State.FALL:
			target_anim = "jump"
		State.ATTACK:
			target_anim = "attack_1"
		State.DEAD:
			target_anim = "dead"
		State.HIT:
			target_anim = "hurt"
	
	if anim.animation != target_anim:
		anim.play(target_anim)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_apply_gravity(delta)
	_update_state()
	_update_direction()
	_apply_state_logic(delta)
	_update_animation()
	
	move_and_slide()


func _area_entered(area: Area2D) -> void:
	#print_debug("area name: ", area.name)
	if area.is_in_group("Bullets"):
		if state != State.DEAD:
			state = State.HIT
			_sub_health(1)
			area.queue_free()
