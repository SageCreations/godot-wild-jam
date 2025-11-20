extends Node

@export var enemy_scenes : Array[PackedScene]
@export var player_path: NodePath
var screen_size: Vector2i
var spawn_x: int
var player: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(enemy_scenes.size() > 0, "ground_scenes Array needs to have at least one scene to spawn")
	assert(player_path, "Player must be assigned to spawner so that it can give the enemies a ref path of the player")
	screen_size = get_window().size
	player = get_node(player_path)


func spawn_enemy() -> void:
	var new_enemy_scene : PackedScene = enemy_scenes.pick_random()
	var new_enemy = new_enemy_scene.instantiate()
	add_child(new_enemy)
	
	new_enemy.set_player(player)
	
	spawn_x = int(player.global_position.x)
	if randi() % 2 == 1: 
		spawn_x += (screen_size.x)
	else:
		spawn_x -= (screen_size.x)
	new_enemy.global_position = Vector2i(spawn_x, 580)
	


func _on_timer_timeout() -> void:
	spawn_enemy()
