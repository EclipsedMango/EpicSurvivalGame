extends Node

const SPAWN_RANGE: float = 200.0 

var height_map: Texture2D = preload("res://heightmap1.png")
var objects: Array[PackedScene] = [
	preload("res://Scenes/rock.tscn"),
	preload("res://Scenes/tree.tscn"),
	preload("res://Scenes/bush.tscn"),
]

func _ready() -> void:
	randomize()
	
	var image := height_map.get_image() 
	
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
	
	for i in range(600):
		var tree: Node3D = objects[1].instantiate()
		var rock: Node3D = objects[0].instantiate()
		var bush: Node3D = objects[2].instantiate()
		
		_setup_spawn(tree, Vector2(1.5, 1.75), Vector2(1.0, 1.0), tree_noise)
		_setup_spawn(rock, Vector2(0.5, 1.25), Vector2(0.5, 1.0), rock_noise)
		_setup_spawn(bush, Vector2(0.6, 0.6), Vector2(1.5, 1.5), bush_noise)

func _setup_spawn(object: Node3D, scale: Vector2, pos: Vector2, noise: Noise) -> void:
	var image := height_map.get_image() 
	
	while true:
		object.position = Vector3(randf_range(-SPAWN_RANGE, SPAWN_RANGE), 0, randf_range(-SPAWN_RANGE, SPAWN_RANGE))
		
		if 0.6 < (noise.get_noise_2d(object.position.x, object.position.z) + 1.0) * 0.5 || \
				randf() < 0.1:
			break
		
		#print("hallo!")
	
	object.rotation.y = randf() * TAU
	
	var height = image.get_pixelv(image.get_size() / 2 + Vector2i(object.position.x, object.position.z)).r
	object.position.y = height * 5.0 - randf_range(pos.x, pos.y)
	
	var rand_scale = randf_range(scale.x, scale.y)
	object.scale = Vector3(rand_scale, rand_scale, rand_scale)
	
	var found_near: bool = false
	
	for other in get_children():
		if other.position.distance_to(object.position) < 1.5:
			object.queue_free()
			found_near = true
			break
	
	if !found_near:
		add_child(object)
