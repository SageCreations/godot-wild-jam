extends CharacterBody2D

@export var bullet : PackedScene

#var _dir : int
var is_shooting = false
var jumping = false
var flip_sprite = false
var jumping_enable = false
var is_reloading = false
var double_jump = false

var bullet_speed = 100
var dash_speed = 9000.0
var dash_counter = 2
var double_jump_counter = 2
var ammo_amount = 1.5
var reload_rate = 1.0

var SPEED = 300.0
const JUMP_VELOCITY = -450.0

func _ready() -> void:
	$AnimatedSprite2D.play("Run")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	#Double Jump
	if Input.is_action_just_pressed("ui_accept") and double_jump_counter > 0:
		velocity.y = JUMP_VELOCITY
		double_jump_counter -= 1
		jumping = true
	elif is_on_floor():
		double_jump_counter = 2
	
	if Input.is_action_just_pressed("Shooting") and ammo_amount > 0:
		is_shooting = true
		spawn_projectile()
		#print_debug("Player Started Shooting", is_shooting)
		await get_tree().create_timer(0.75).timeout
		is_shooting = false
		ammo_amount -= 0.1
		#print_debug("Player Stopped Shooting", is_shooting)
	elif ammo_amount <= 0:
		print_debug("Player has ran out of ammo : ", ammo_amount)

	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		flip_sprite = true
		
	
	#DASH MECHANIC
	if dash_counter >= 0:
		if direction == -1 and Input.is_action_just_released("Dash"):
			velocity.x = direction * SPEED - dash_speed
			dash_counter -= 1
		elif direction == +1 and Input.is_action_just_released("Dash") :
			velocity.x = direction * SPEED + dash_speed
			dash_counter -= 1
			
	if is_on_floor() and Input.is_action_pressed("Reload") and ammo_amount <= 0 :
		is_reloading = true
		#print_debug("Reloading Started : ", is_reloading)
		await get_tree().create_timer(1.0).timeout
		is_reloading = false
		ammo_amount = 1.5
		print_debug("Reloading Stopped : ", is_reloading)
		print_debug("Gun Loaded : ", ammo_amount)
	
	if direction == -1 :
		flip_sprite = true
	else :
		flip_sprite = false
	move_and_slide()
	animation_handler()
	#set_dir(direction)
#
#func set_dir(d: int):
	#_dir = d 
	
func spawn_projectile() -> void:
	if flip_sprite == true : 
		var bullet_instance = bullet.instantiate()
		add_child(bullet_instance)
		bullet_instance.global_position = Vector2(global_position.x - 50, global_position.y -10)
		await get_tree().create_timer(0.2).timeout
		bullet_instance.position.x -= bullet_speed
		await get_tree().create_timer(0.2).timeout
		bullet_instance.position.x -= bullet_speed
		await get_tree().create_timer(0.2).timeout
		bullet_instance.position.x -= bullet_speed
		await get_tree().create_timer(0.2).timeout
		bullet_instance.position.x -= bullet_speed
		await get_tree().create_timer(0.5).timeout
		bullet_instance.free()
	elif flip_sprite == false : 
		var bullet_instance = bullet.instantiate()
		add_child(bullet_instance)
		bullet_instance.global_position = Vector2(global_position.x + 50, global_position.y -10)
		bullet_instance.position.x += bullet_speed
		await get_tree().create_timer(0.2).timeout
		bullet_instance.position.x += bullet_speed
		await get_tree().create_timer(0.2).timeout
		bullet_instance.position.x += bullet_speed
		await get_tree().create_timer(0.2).timeout
		bullet_instance.position.x += bullet_speed
		await get_tree().create_timer(0.2).timeout
		bullet_instance.position.x += bullet_speed
		await get_tree().create_timer(0.5).timeout
		bullet_instance.free()
	
func animation_handler() -> void:
		if flip_sprite == true :
			$AnimatedSprite2D.offset = Vector2(-21.35,-32.5)
			$AnimatedSprite2D.flip_h = false
		elif flip_sprite == false:
			$AnimatedSprite2D.offset = Vector2(21.5,-32.5)
			$AnimatedSprite2D.flip_h = true
		if is_on_floor():
			$AnimatedSprite2D.play("Run")
		elif jumping == true :
			$AnimatedSprite2D.play("Jump")
			$AnimatedSprite2D.stop()
		if is_shooting == true: 
			$AnimatedSprite2D.play("Shoot")
		if is_reloading == true: 
			$AnimatedSprite2D.speed_scale = 0.5
			$AnimatedSprite2D.play("Reload")
