extends Node

const SPAWN_RANGE: float = 200.0 

var rock_res: PackedScene = preload("res://Scenes/rock.tscn")
var height_map: Texture2D = preload("res://heightmap1.png")

func _ready() -> void:
	randomize()
	
	var image := height_map.get_image() 
	
	for i in range(600):
		var rock: Node3D = rock_res.instantiate()
		rock.position = Vector3(randf_range(-SPAWN_RANGE, SPAWN_RANGE), 0, randf_range(-SPAWN_RANGE, SPAWN_RANGE))
	
		rock.rotation.y = randf() * TAU
	
		var height = image.get_pixelv(image.get_size() / 2 + Vector2i(rock.position.x, rock.position.z)).r
		rock.position.y = height * 5.0 - randf_range(0.5, 1.0)
	
		var found_near: bool = false
	
		for other in get_children():
			if other.position.distance_to(rock.position) < 1.5:
				rock.queue_free()
				found_near = true
				break
	
		if !found_near:
			add_child(rock)
