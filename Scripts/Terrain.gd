@tool
extends MeshInstance3D 

@onready var collision: CollisionShape3D = $"../CollisionShape3D"
@onready var grass_origin: Node3D = $"../../GrassOrigin"

@export var gradient: Gradient
@export var noise_major_t: NoiseTexture2D
@export var noise_minor_t: NoiseTexture2D
@export var water_noise: NoiseTexture2D
@export var goodbye: bool:
	set(value):
		_ready()
	get:
		return false
 
func _ready() -> void:
	noise_major_t.noise.seed = randi()
	noise_minor_t.noise.seed = randi()
	water_noise.noise.seed = randi()
 
	var waterNoise := water_noise.get_image()
	var noise_major := noise_major_t.get_image()
	var noise_minor := noise_minor_t.get_image()
 
	var heightmap_data := PackedFloat32Array()
	heightmap_data.resize(256 * 256)
	var heightmap_collision_data := PackedFloat32Array()
	heightmap_collision_data.resize(256 * 256)

	print("Generating Floor...")
	var surface_tool := SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.set_normal(Vector3(0, 0, 1))
	surface_tool.set_uv(Vector2(0, 0))
 
	for y in range(256):
		for x in range(256):
			var pos0 := _get_height(x, y, noise_major, noise_minor, waterNoise)
			var pos1 := _get_height(x+1, y  , noise_major, noise_minor, waterNoise)
			var pos2 := _get_height(x  , y+1, noise_major, noise_minor, waterNoise)
			var pos3 := _get_height(x+1, y+1, noise_major, noise_minor, waterNoise)
 
			surface_tool.add_vertex(pos0)
			surface_tool.add_vertex(pos1)
			surface_tool.add_vertex(pos2)
 
			surface_tool.add_vertex(pos3)
			surface_tool.add_vertex(pos2)
			surface_tool.add_vertex(pos1)

			heightmap_data[x + y * 256] = pos0.y * 7.5
			heightmap_collision_data[x + y * 256] = pos0.y * 256.0

	print("Finishing Mesh Generation")
	surface_tool.index()
	surface_tool.generate_normals()
	surface_tool.generate_tangents()
	mesh = surface_tool.commit()
 
	print("Creating Collision")
	collision.scale = Vector3.ONE * 1.0 / 256.0
	collision.position.x = -0.5 / 256.0
	collision.position.z = -0.5 / 256.0
	collision.shape.map_data = heightmap_collision_data
 
	var heightmap := Image.create_from_data(256, 256, false, Image.FORMAT_RF, heightmap_data.to_byte_array())
	var itex := ImageTexture.create_from_image(heightmap)
	for grass_particles in grass_origin.get_children():
		grass_particles.process_material.set_shader_parameter("map_heightmap", itex)

	$TextureRect.texture = itex

	print("Finished Creating Floor")
 
func _create_noise() -> FastNoiseLite:
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 1.0
	noise.seed = randi() | (randi() << 32)
	return noise
 
 
func _get_height(x: int, y: int, noise_major: Image, noise_minor: Image, waterNoise: Image) -> Vector3:
	var value: float = 0.0
	var pos := Vector2(float(x) / 256.0 - 0.5, float(y) / 256.0 - 0.5)
 
	var dist: float = max(abs(pos.x), abs(pos.y)) * 2.0
 
	var major = noise_major.get_pixel(x, y).r * 0.75
	var minor = noise_minor.get_pixel(x, y).r * 0.25
	var water = waterNoise.get_pixel(x, y).r * 0.25
 
	value = lerpf(major, minor, 0.5) * (1.0 - gradient.sample(dist).r) * 2.0
 
	return Vector3(pos.x, value * 0.4, pos.y)
