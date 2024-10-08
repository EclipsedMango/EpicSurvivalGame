shader_type particles;

uniform float instance_rows;
uniform float instance_rot_randomize = 2.5;
uniform float instance_spacing = 1.0;
uniform float instance_scale_x = 1.0;
uniform	float instance_scale_y = 1.0;
uniform float instance_scale_z = 1.0;
uniform float instance_scale_randomize = 1.0;
uniform float instance_pos_randomize : hint_range(0.0, 50.0) =  2.0;
uniform float instance_scale_min = 0.2;
uniform float instance_scale_max = 1.2;
uniform float min_spawn_level = 0.0;
uniform float _coverage_altitude = 10.0;
uniform float _coverage_range = 100.0;
uniform float _slope_coverage = 0.5;
uniform float clumping_strength : hint_range(0.0, 100.0) = 20.0;
uniform float scale = 1.0;
uniform mat3 terrain_normal_basis;

uniform sampler2D funny;
uniform sampler2D map_heightmap;
uniform sampler2D map_normalmap;
uniform bool instance_orient_to_normal = false;
uniform float instance_orientation_influence : hint_range(0.0, 10.0) = 1.0;
uniform vec3 terrain_offset;
uniform float terrain_amplitude;
uniform vec2 map_heightmap_size = vec2(2000.0, 2000.0);
uniform vec2 map_normalmap_size = vec2(2000.0, 2000.0);
uniform sampler2D map_clumpmap;

float sdCircle( vec2 p, float r ) {
    return length(p) - r;
}

float get_height(vec2 pos) {
	pos -= .5 * map_heightmap_size * scale;
	pos /= map_heightmap_size * scale;
	return terrain_amplitude * scale * texture(map_heightmap, pos).r / 7.5 + terrain_offset.y * scale;
}

vec3 unpack_normalmap(vec3 rgb) {
vec3 n = rgb.xzy * 2.0 - vec3(1.0);
n.z *= -1.0;
return n;
}	

vec3 get_normal(vec2 pos) {
	pos -= 0.5 * map_normalmap_size;
	pos /= map_normalmap_size;
	return terrain_normal_basis * unpack_normalmap(texture(map_normalmap, pos).rgb);
}

float get_clumps(vec2 pos) {
	pos -= 0.5 * map_heightmap_size * scale;
	pos /= map_heightmap_size * scale;
	return 100.0 * texture(map_clumpmap, pos).r;
}

vec3 get_pos(float index) {
	vec3 pos = vec3(0.0, 1.0, 0.0);
	pos.x = mod(index, instance_rows);
	pos.z = (index - pos.x) / instance_rows;

	return pos;
}

vec3 get_pos_circle(float index) {
  float magnitude = floor(log2(index + 1.0));
  float positions = pow(2.0, magnitude);
  float angle = mod(index, positions) / positions * 6.283185;

  vec3 pos = vec3(0.0, 0.0, 0.0);
  pos.xz = vec2(cos(angle), sin(angle)) * magnitude;

  return pos;
}

void start() {    
    // get position
    vec3 pos = get_pos(float(INDEX));
	
	// center the emitter
	pos.x -= instance_rows * 0.5;
	pos.z -= instance_rows * 0.5;
	
	// apply instance spacing
	pos *= instance_spacing;
	
	// center on position of emitter
	pos.x += EMISSION_TRANSFORM[3][0] - mod(EMISSION_TRANSFORM[3][0], instance_spacing);
	pos.z += EMISSION_TRANSFORM[3][2] - mod(EMISSION_TRANSFORM[3][2], instance_spacing);
	
	// add noise 
	//vec3 noise = texture(map_heightmap, pos.xz * 0.1).rgb;
	vec3 noise = texture(funny, pos.xz * 0.1).rgb;
	pos.x += noise.z * instance_spacing * instance_pos_randomize;
	pos.z -= noise.x * instance_spacing * instance_pos_randomize;

	const float slope_distance_check = 0.1;
	
	vec2 offset = terrain_offset.xz * scale;

	// apply height
	pos.y = get_height(pos.xz + offset);
	float yclump = get_clumps(pos.xz);

	float yxp = get_height(pos.xz + vec2(slope_distance_check, 0.0) + offset);
	float yxm = get_height(pos.xz + vec2(-slope_distance_check, 0.0) + offset);
	float yzp = get_height(pos.xz + vec2(0.0, slope_distance_check) + offset);
	float yzm = get_height(pos.xz + vec2(0.0, -slope_distance_check) + offset);
    
	if (abs(pos.y) < min_spawn_level * scale) {
		pos.y = -10000.0;
	}
	
	// hide parts from steep areas
	if ((abs(yxp - pos.y) > _slope_coverage && abs(yxm - pos.y) > _slope_coverage) ||
		(abs(yzp - pos.y) > _slope_coverage && abs(yzm - pos.y) > _slope_coverage)) {
		pos.y = -10000.0;
	}
    
	if (abs(pos.y) < _coverage_altitude*5.0-_coverage_range) {
		pos.y = -10000.0;
	}
    
	if (abs(pos.y) > _coverage_altitude*5.0+_coverage_range) {
		pos.y = -10000.0;
	}

	// clumping
	vec3 clumps = texture(map_clumpmap, pos.zx).rgb;
	if (abs(yclump) < clumping_strength) {
		pos.y = -10000.0;
	}
	
	// rotate transformpos.xz * 0.1).rgb;
	vec3 tex_scale = vec3(1.0);

	vec3 base_scale = vec3(mix(instance_scale_min, instance_scale_max, noise.x)*instance_scale_x,mix(instance_scale_min, instance_scale_max, noise.y)*instance_scale_y,mix(instance_scale_min, instance_scale_max, noise.z)*instance_scale_z );
	base_scale *= base_scale*instance_scale_randomize;
	base_scale = sign(base_scale) * max(abs(base_scale), 0.1);
	
				// update transform
	pos.x += cos(noise.x * instance_pos_randomize) * base_scale.x;
	pos.z += sin(noise.z * instance_pos_randomize) * base_scale.z; 
	
	// re-transform to orient to normal if the setting is on	
	if (instance_orient_to_normal == true){
	TRANSFORM[1].xyz = get_normal(pos.xz) * instance_orientation_influence;
	TRANSFORM[2].xyz = sin(get_normal(pos.zx) * faceforward(vec3(1.0),TRANSFORM[1].xyz, vec3(0.0, 0.0, 1.0))) * instance_orientation_influence ;
	TRANSFORM[0].xyz = sin(get_normal(pos.zx) * faceforward(vec3(1.0),TRANSFORM[1].xyz, vec3(1.0, 0.0, 0.0))) * instance_orientation_influence ;
	}
	else {
		TRANSFORM[0].xyz = vec3(0.0);
		TRANSFORM[1].xyz = vec3(0.0);
		TRANSFORM[2].xyz = vec3(0.0);}
	
	// finalize transform positioning and scaling including randomizations	
	TRANSFORM[3][0] = pos.x;
	TRANSFORM[3][1] = pos.y;
	TRANSFORM[3][2] = pos.z;
	
	TRANSFORM[0][0] = cos(noise.x * instance_rot_randomize) * base_scale.x;
	TRANSFORM[0][2] = -sin(noise.x * instance_rot_randomize) * base_scale.x;
	TRANSFORM[2][0] = sin(noise.z * instance_rot_randomize) * base_scale.z;
	TRANSFORM[2][2] = cos(noise.z * instance_rot_randomize) * base_scale.z;
	
	TRANSFORM[0][0]  = base_scale.x;
	TRANSFORM[1][1] =  base_scale.y;
	TRANSFORM[2][2]  = base_scale.z;

}	