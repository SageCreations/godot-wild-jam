extends CharacterBody2D

@export var bullet : PackedScene

var saved_dir: int = 1
var is_shooting = false
var jumping = false
var flip_sprite = false
var jumping_enable = false
var is_reloading = false
var double_jump = false

var bullet_speed = 100
var dash_speed: float = 5000.0
var dash_distance: float = 500.0
var dash_counter = 2
var double_jump_counter = 2
var ammo_count: int = 30
var max_ammo: int = 30
var reload_rate = 1.5
var fire_rate = 0.3

var SPEED = 300.0
const JUMP_VELOCITY = -450.0

enum State {
	IDLE,
	RUN,
	JUMP,
	FALL,
	ATTACK,
	RELOAD,
	DEAD,
}
var state: State = State.RUN

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	# Add the gravity.
	velocity += get_gravity() * delta
	
	if state == State.RELOAD or state == State.DEAD:
		return
	
	#Double Jump
	if Input.is_action_just_pressed("ui_accept") and double_jump_counter > 0:
		velocity.y = JUMP_VELOCITY
		double_jump_counter -= 1
		state = State.JUMP
	elif is_on_floor():
		if Input.is_action_pressed("Reload") and ammo_count < max_ammo :
			var prev_state = state
			state = State.RELOAD
			$AnimatedSprite2D.play("Reload")
			await get_tree().create_timer(1.0).timeout
			state = prev_state
			ammo_count = max_ammo
		else:
			state = State.RUN
			double_jump_counter = 2
	
	if Input.is_action_pressed("Shooting") and ammo_count > 0:
		state = State.ATTACK
		if $Shooting_Cooldown.is_stopped():
			$AnimatedSprite2D.play("Shoot")
			spawn_projectile()
			ammo_count -= 1
			$Shooting_Cooldown.start(fire_rate)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = 0
	
	#DASH MECHANIC
	#if Input.is_action_just_released("Dash"):
		#position += transform.x * (saved_dir * dash_speed) * delta
	
	if direction == -1 or direction == 1 :
		saved_dir = int(direction)
	
	if saved_dir == 1:
		flip_sprite = false
	else:
		flip_sprite = true
	
	_update_animation()
	move_and_slide()


func spawn_projectile() -> void:
	assert(bullet, "Scene needs to be set for the bullet variable on the player.")
	var bullet_instance = bullet.instantiate()
	get_parent().add_child(bullet_instance)
	bullet_instance.set_dir(saved_dir)
	bullet_instance.global_position = Vector2(global_position.x - 50, global_position.y -10) if flip_sprite else Vector2(global_position.x + 50, global_position.y -10)


func _update_animation() -> void:
	var target_anim: String = ""
	
	if flip_sprite == true :
		$AnimatedSprite2D.offset = Vector2(-21.35,-32.5)
		$AnimatedSprite2D.flip_h = false
	elif flip_sprite == false:
		$AnimatedSprite2D.offset = Vector2(21.5,-32.5)
		$AnimatedSprite2D.flip_h = true
	
	match state:
		State.IDLE:
			target_anim = "Idle"
		State.RUN:
			target_anim = "Run"
		State.JUMP:
			target_anim = "Jump"
		State.FALL:
			target_anim = "Jump"
		State.ATTACK:
			target_anim = "Shoot"
		State.RELOAD:
			target_anim = "Reload"
		State.DEAD:
			target_anim = "Die"
	
	if $AnimatedSprite2D.animation != target_anim:
		$AnimatedSprite2D.play(target_anim)
