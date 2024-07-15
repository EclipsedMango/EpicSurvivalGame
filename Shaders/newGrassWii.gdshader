shader_type particles;

uniform sampler2D funny;
uniform sampler2D map_heightmap;

uniform vec2 map_heightmap_size = vec2(2000.0, 2000.0);
uniform vec3 terrain_offset;

uniform float instance_pos_randomize : hint_range(0.0, 50.0) =  2.0;
uniform float terrain_amplitude;
uniform float instance_rows;
uniform float instance_spacing = 1.0;

float get_height(vec2 pos) {
	pos -= 0.5 * map_heightmap_size;
	pos /= map_heightmap_size;
	return terrain_amplitude * texture(map_heightmap, pos).r / 7.5 + terrain_offset.y;
}

vec3 get_pos(float index) {
	vec3 pos = vec3(0.0, 1.0, 0.0);
	pos.x = mod(index, instance_rows);
	pos.z = (index - pos.x) / instance_rows;

	return pos;
}

void start() {
	vec3 pos = get_pos(float(INDEX));
	
	pos.x -= instance_rows * 0.5;
	pos.z -= instance_rows * 0.5;
	
		// apply instance spacing
	pos *= instance_spacing;
	
	// center on position of emitter
	pos.x += EMISSION_TRANSFORM[3][0] - mod(EMISSION_TRANSFORM[3][0], instance_spacing);
	pos.z += EMISSION_TRANSFORM[3][2] - mod(EMISSION_TRANSFORM[3][2], instance_spacing);
	
	vec3 noise = texture(funny, pos.xz * 0.1).rgb;
	pos.x += noise.z * instance_spacing * instance_pos_randomize;
	pos.z -= noise.x * instance_spacing * instance_pos_randomize;
	
	pos.y = get_height(pos.xz + terrain_offset.xz);
	float y2 = get_height(pos.xz + vec2(1.0, 0.0));
	float y3 = get_height(pos.xz + vec2(0.0, 1.0));
	
	TRANSFORM[3][0] = pos.x;
	TRANSFORM[3][1] = pos.y;
	TRANSFORM[3][2] = pos.z;
	
}