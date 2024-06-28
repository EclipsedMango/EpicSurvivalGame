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
	
	for i in range(600):
		var rock: Node3D = objects[randi() % objects.size()].instantiate()
		rock.position = Vector3(randf_range(-SPAWN_RANGE, SPAWN_RANGE), 0, randf_range(-SPAWN_RANGE, SPAWN_RANGE))
	
		rock.rotation.y = randf() * TAU
	
		var height = image.get_pixelv(image.get_size() / 2 + Vector2i(rock.position.x, rock.position.z)).r
		rock.position.y = height * 5.0 - randf_range(0.5, 1.0)
	
		var rand_scale = randf_range(0.5, 1.25)
		rock.scale = Vector3(rand_scale, rand_scale, rand_scale)
	
		var found_near: bool = false
	
		for other in get_children():
			if other.position.distance_to(rock.position) < 1.5:
				rock.queue_free()
				found_near = true
				break
	
		if !found_near:
			add_child(rock)
