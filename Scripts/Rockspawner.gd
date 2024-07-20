extends Node3D

const SPAWN_RANGE: float = 100.0 

var height_map: Texture2D = preload("res://heightmap1.png")
var objects: Array[PackedScene] = [
	preload("res://Scenes/rock.tscn"),
	preload("res://Scenes/tree.tscn"),
	preload("res://Scenes/bush.tscn"),
]

func _ready() -> void:
	get_tree().create_timer(1).timeout.connect(_generate)

func _generate() -> void:
	print("Generating Decorations")
	var tree_noise := FastNoiseLite.new()
	tree_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	tree_noise.frequency = 0.01
	tree_noise.seed = randi() | (randi() << 32)
	
	var rock_noise := FastNoiseLite.new()
	rock_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	rock_noise.frequency = 0.01
	rock_noise.seed = randi() | (randi() << 32)
	
	var bush_noise := FastNoiseLite.new()
	bush_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	bush_noise.frequency = 0.01
	
	for i in range(150):
		var tree: Node3D = objects[1].instantiate()
		var rock: Node3D = objects[0].instantiate()
		var bush: Node3D = objects[2].instantiate()
		
		while !_ray_based_spawning(tree, Vector2(1.5, 1.75), Vector2(1.0, 1.0), tree_noise):
			pass
		
		while !_ray_based_spawning(rock, Vector2(0.5, 1.25), Vector2(0.5, 1.0), rock_noise):
			pass
		
		while !_ray_based_spawning(bush, Vector2(0.6, 0.6), Vector2(1.5, 1.5), bush_noise):
			pass

func _ray_based_spawning(object: Node3D, scale: Vector2, pos: Vector2, noise: Noise) -> bool:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	
	var target := Vector3.ZERO
	
	while true:
		target = Vector3(randf_range(-SPAWN_RANGE, SPAWN_RANGE), 150, randf_range(-SPAWN_RANGE, SPAWN_RANGE))
		
		if 0.6 < (noise.get_noise_2d(target.x, target.z) + 1.0) * 0.5 || \
			randf() < 0.1:
				break
	
	object.rotation.y = randf() * TAU
	
	var ray_length = 350.0
	var origin: Vector3 = target
	var end = origin + Vector3(0, -ray_length, 0)
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	query.collision_mask = 1
	query.collide_with_areas = true
	query.hit_back_faces = true
	var result: Dictionary = space_state.intersect_ray(query)
	
	if result.has("collider"):
		target.y = result.position.y - 0.25
		if result.position.y < 11.5 * 4.0:
			object.queue_free()
			return false
	
	var rand_scale = randf_range(scale.x, scale.y)
	object.scale = Vector3(rand_scale, rand_scale, rand_scale)
	
	for other in get_children():
		if other.global_position.distance_to(target) < 1.5:
			object.queue_free()
			return false
	
	add_child(object)
	object.global_position = target
	return true
