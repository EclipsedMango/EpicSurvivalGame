@tool
extends MeshInstance3D
 
@onready var collision_shape_3d: CollisionShape3D = $"../CollisionShape3D"
@onready var grass_particles: GPUParticles3D = $"../../GrassOrigin/GPUParticles3D"

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
 
	var heightmap_data := PackedByteArray()
	heightmap_data.resize(256 * 256)

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

			heightmap_data[(x + y * 256)] = pos0.y * 255

	print("Finishing Mesh Generation")
	surface_tool.index()
	surface_tool.generate_normals()
	surface_tool.generate_tangents()
	mesh = surface_tool.commit()
 
	print("Creating Collision")
	collision_shape_3d.shape = ConcavePolygonShape3D.new()
	collision_shape_3d.shape.set_faces(mesh.get_faces())
	collision_shape_3d.scale = Vector3.ONE
 
	var heightmap := Image.create_from_data(256, 256, false, Image.FORMAT_L8, heightmap_data)
	var itex := ImageTexture.create_from_image(heightmap)
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
	const sea_dist: float = 0.8
	const montan_dist: float = 0.2
 
	var value: float = 0.0
	var pos := Vector2(float(x) / 256.0 - 0.5, float(y) / 256.0 - 0.5)
 
	var dist: float = max(abs(pos.x), abs(pos.y)) * 2.0
 
	var major = noise_major.get_pixel(x, y).r * 0.75
	var minor = noise_minor.get_pixel(x, y).r * 0.25
	var water = waterNoise.get_pixel(x, y).r * 0.25
 
	value = lerpf(major, minor, 0.5) * (1.0 - gradient.sample(dist).r) * 2.0
 
	return Vector3(pos.x, value * 0.4, pos.y)
