extends MeshInstance3D
#
@onready var collision_shape_3d: CollisionShape3D = $"../CollisionShape3D"

@export var noise_t: NoiseTexture2D
@export var noise_f: NoiseTexture2D

const hallo: float = 0.48

func _ready() -> void:
	noise_t.noise.seed = randi()
	noise_f.noise.seed = randi()

	#var noise := _create_noise()
	#var noise2 := _create_noise()
	var waterNoise := _create_noise()
	var noise := noise_t.get_image()
	var noise2 := noise_f.get_image()

	var data := PackedFloat32Array()
	data.resize(256*256)
#
	print("Generating Mesh...")
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(256, 256)
	plane_mesh.subdivide_depth = 255
	plane_mesh.subdivide_width = 255
#
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)
	var surface_data = surface_tool.commit_to_arrays()
	var vertices = surface_data[ArrayMesh.ARRAY_VERTEX]
	
	for i in range(vertices.size()):
		var value: float = 0.0
		
		var x := int(vertices[i].x) + 127
		var y := int(vertices[i].z) + 127
		var pos := Vector2(float(x) / 256.0 - 0.5, float(y) / 256.0 - 0.5)
		
		var dist: float = max(abs(pos.x), abs(pos.y))
		
		if pos.x > waterNoise.get_noise_2dv(pos) + 0.25 || \
				pos.y > waterNoise.get_noise_2dv(pos) + 0.25:
			value = min(max(-dist, hallo), 0.08) - 0.1
		
		if dist > hallo:
			value += min(max(-dist, hallo), 0.08) - 0.1
		else:
			value += lerpf(noise.get_pixel(x, y).r, noise2.get_pixel(x, y).r, 0.5)
		
		value *= 0.1
		collision_shape_3d.shape.map_data[x + y*256] = value * 256
		data[x + y*256] = value
		vertices[i].y = value
		
	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, data)
	
	surface_tool.create_from(array_mesh, 0)
	surface_tool.generate_normals()
	
	mesh = surface_tool.commit()
	
	material_override.set_shader_parameter("heightMap", data)
	
	#collision_shape_3d.shape.map_data = data
	collision_shape_3d.scale = Vector3.ONE * 0.00390625


func _create_noise() -> FastNoiseLite:
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 1.0
	noise.seed = randi() | (randi() << 32)
	return noise
