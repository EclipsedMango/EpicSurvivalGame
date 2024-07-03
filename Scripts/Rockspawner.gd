extends Node

const SPAWN_RANGE: float = 200.0 

var height_map: Texture2D = preload("res://heightmap1.png")
var objects: Array[PackedScene] = [
	preload("res://Scenes/rock.tscn"),
	preload("res://Scenes/tree.tscn"),
]

func _ready() -> void:
	randomize()
	
	var image := height_map.get_image() 
	
	for i in range(300):
		var tree: Node3D = objects[1].instantiate()
		var rock: Node3D = objects[0].instantiate()
		
		_setup_spawn(tree, Vector2(1.5, 1.75), Vector2(1.0, 1.0))
		_setup_spawn(rock, Vector2(0.5, 1.25), Vector2(0.5, 1.0))

func _setup_spawn(object: Node3D, scale: Vector2, pos: Vector2) -> void:
	var image := height_map.get_image() 
	
	object.position = Vector3(randf_range(-SPAWN_RANGE, SPAWN_RANGE), 0, randf_range(-SPAWN_RANGE, SPAWN_RANGE))
	
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
