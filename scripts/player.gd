extends CharacterBody2D

@export var bullet : PackedScene

var saved_dir: int = 1
var is_shooting = false
var jumping = false
var flip_sprite = false
var jumping_enable = false
var is_reloading = false
var double_jump = false
var is_hurt = false

var bullet_speed = 100
var dash_speed: float = 5000.0
var dash_distance: float = 500.0
var dash_counter = 2
var double_jump_counter = 1
var ammo_count: int = 30
var max_ammo: int = 30
var reload_rate: float = 1.5
var fire_rate: float = 0.3

var double_points: bool = false

@onready var reload_bar := $Control/ProgressBar
@onready var reload_timer := $Reload_Timer

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
	HURT,
}
var state: State = State.RUN

func _ready() -> void:
	reload_bar.visible = false

func _player_hit() -> void:
		AirFilter.sub_points(5)
		is_hurt = true
		if AirFilter.air <= 0:
			state = State.DEAD
		else:
			$AnimatedSprite2D.play("hurt")
			await get_tree().create_timer(1.0).timeout
			is_hurt = false


func _on_reload_timer_timeout() -> void:
	state = State.RUN
	ammo_count = max_ammo
	reload_bar.visible = false
	reload_bar.value = 0


func _physics_process(delta: float) -> void:
	_update_animation()
	# Add the gravity.
	velocity += get_gravity() * delta
	
	if state == State.DEAD:
		get_parent().game_over = true
		return
	
	if state == State.RELOAD:
		reload_bar.value = 100 - ((reload_timer.time_left / reload_timer.wait_time) * 100)
		return
	
	#Double Jump
	if Input.is_action_just_pressed("ui_accept") and double_jump_counter > 0:
		velocity.y = JUMP_VELOCITY
		double_jump_counter -= 1
		AirFilter.sub_points(1)
		state = State.JUMP
	
		# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = 0
	
	if is_on_floor():
		if Input.is_action_pressed("Reload") and ammo_count < max_ammo and velocity.x == 0:
			state = State.RELOAD
			$AnimatedSprite2D.play("Reload")
			$Click_Sound.pitch_scale = 0.6
			$Click_Sound.play()
			reload_bar.visible = true
			reload_timer.start(reload_rate)
		else:
			state = State.RUN
			double_jump_counter = 1
	
	if Input.is_action_pressed("Shooting") and ammo_count <= 0:
		state = State.ATTACK
		if $Shooting_Cooldown.is_stopped():
			$Click_Sound.pitch_scale = 1.2
			$Click_Sound.play()
			$Shooting_Cooldown.start(fire_rate)
	
	if Input.is_action_pressed("Shooting") and ammo_count > 0:
		state = State.ATTACK
		if $Shooting_Cooldown.is_stopped():
			$AnimatedSprite2D.play("Shoot")
			$Shoot_Sound.play()
			spawn_projectile()
			ammo_count -= 1
			$Shooting_Cooldown.start(fire_rate)
	
	#DASH MECHANIC
	#if Input.is_action_just_released("Dash"):
		#position += transform.x * (saved_dir * dash_speed) * delta
	
	if direction == -1 or direction == 1 :
		saved_dir = int(direction)
	
	if saved_dir == 1:
		flip_sprite = false
	else:
		flip_sprite = true
	
	
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


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("2xMod"):
		double_points = true
		$double_pts_timer.start(5.0)
	elif body.is_in_group("FireRate"):
		fire_rate = 0.1
		$fire_rate_powerup_timer.start(10.0)
	elif body.is_in_group("MaxAmmoUpgrade"):
		max_ammo += 5
	elif body.is_in_group("ReloadSpeed"):
		reload_rate = 0.75
		$Reload_Speed.start(15.0)
	elif body.is_in_group("AirUp"):
		AirFilter.add_points(15)
	
	$Powerup_Sound.play()

	body.queue_free()


func _on_double_pts_timer_timeout() -> void:
	double_points = false


func _on_fire_rate_powerup_timer_timeout() -> void:
	fire_rate = 0.3


func _on_reload_speed_timeout() -> void:
	reload_rate = 1.5
