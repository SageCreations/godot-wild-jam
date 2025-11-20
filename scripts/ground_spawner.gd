extends Node

@export var ground_scenes : Array[PackedScene]
var screen_size: Vector2i
var spawn_x : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(ground_scenes.size() > 0, "ground_scenes Array needs to have at least one scene to spawn")
	screen_size = get_window().size
	SignalBus.Ground_Needed.connect(_on_ground_needed)

func _on_ground_needed() -> void:
	var new_ground_scene : PackedScene = ground_scenes.pick_random()
	var new_ground = new_ground_scene.instantiate()
	spawn_x = spawn_x + screen_size.x*2
	new_ground.position = Vector2i(spawn_x, 647)
	add_child(new_ground)
	
	#call_deferred("new ground position: ", Vector2i(spawn_x, 647))
	
