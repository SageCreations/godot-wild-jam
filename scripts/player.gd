extends CharacterBody2D

var is_shooting = false
var jumping = false
var flip_sprite = false

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _ready() -> void:
	$AnimatedSprite2D.play("Run")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jumping = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		#print_debug(direction)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		flip_sprite = true
		#print_debug(direction)
	
	if direction == -1 :
		flip_sprite = true
	else :
		flip_sprite = false

	move_and_slide()
	animation_handler()
	
func animation_handler() -> void:
		if flip_sprite == true :
			$AnimatedSprite2D.offset = Vector2(-21.35,-32.5)
			$AnimatedSprite2D.flip_h = false
		elif flip_sprite == false:
			$AnimatedSprite2D.offset = Vector2(21.5,-32.5)
			$AnimatedSprite2D.flip_h = true
		if is_on_floor():
			$AnimatedSprite2D.play("Run")
			#print_debug("Running")
		elif jumping == true :
			$AnimatedSprite2D.play("Jump")
			$AnimatedSprite2D.stop()
			#print_debug("Jumping")
