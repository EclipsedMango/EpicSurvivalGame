@tool
extends MeshInstance3D

@onready var collision_shape_3d: CollisionShape3D = $"../CollisionShape3D"

@export var noise_t: NoiseTexture2D
@export var noise_f: NoiseTexture2D
@export var water_noise: NoiseTexture2D
@export var goodbye: bool:
	set(value):
		_ready()
	get:
		return false

func _ready() -> void:
	noise_t.noise.seed = randi()
	noise_f.noise.seed = randi()
	water_noise.noise.seed = randi()
	
	var waterNoise := water_noise.get_image()
	var noise := noise_t.get_image()
	var noise2 := noise_f.get_image()
	
	print("Generating Floor...")
	var surface_tool := SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.set_normal(Vector3(0, 0, 1))
	surface_tool.set_uv(Vector2(0, 0))
	
	for y in range(256):
		for x in range(256):
			var pos0 := _get_height(x, y, noise, noise2, waterNoise)
			var pos1 := _get_height(x+1, y  , noise, noise2, waterNoise)
			var pos2 := _get_height(x  , y+1, noise, noise2, waterNoise)
			var pos3 := _get_height(x+1, y+1, noise, noise2, waterNoise)
			
			surface_tool.add_vertex(pos0)
			surface_tool.add_vertex(pos1)
			surface_tool.add_vertex(pos2)
			
			surface_tool.add_vertex(pos3)
			surface_tool.add_vertex(pos2)
			surface_tool.add_vertex(pos1)
	
	print("Finishing Mesh Generation")
	surface_tool.index()
	surface_tool.generate_normals()
	surface_tool.generate_tangents()
	mesh = surface_tool.commit()
	
	print("Creating Collision")
	collision_shape_3d.shape = ConcavePolygonShape3D.new()
	collision_shape_3d.shape.set_faces(mesh.get_faces())
	collision_shape_3d.scale = Vector3.ONE
	
	print("Finished Creating Floor")

func _create_noise() -> FastNoiseLite:
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 1.0
	noise.seed = randi() | (randi() << 32)
	return noise


func _get_height(x: int, y: int, noise: Image, noise2: Image, waterNoise: Image) -> Vector3:
	const hallo: float = 0.5
	
	var value: float = 0.0
	var pos := Vector2(float(x) / 256.0 - 0.5, float(y) / 256.0 - 0.5)
	
	var dist: float = max(abs(pos.x), abs(pos.y))
	
	var test = noise.get_pixel(x, y).r * 0.25
	var test2 = noise2.get_pixel(x, y).r * 0.5
	var water = waterNoise.get_pixel(x, y).r * 0.25
	
	if dist > hallo:
		value = min(-dist + hallo + 0.01, lerpf(test, test2, 0.5))
	else:
		value = lerpf(test, test2, 0.5)
	
	if abs(pos.x) > water + 0.25 || abs(pos.y) > water + 0.25:
		#value *= min(value, value * ((0.5 - dist) * 1.0))
		value *= value * ((0.5 - dist) * 5.0)
		#value += min(max(-dist, hallo), 0.1) - 0.1
	
	return Vector3(pos.x, value * 0.4, pos.y)
