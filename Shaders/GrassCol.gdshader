shader_type spatial;
render_mode blend_mix, cull_disabled, diffuse_toon, specular_toon, depth_prepass_alpha;

uniform vec3 tipCol: source_color;
uniform vec3 baseCol: source_color;
uniform vec3 mainCol: source_color;
uniform vec3 secondaryCol: source_color;
uniform vec3 biomeCol: source_color;

uniform sampler2D groupWindNoise;
uniform sampler2D windNoise;
uniform sampler2D colNoise;
uniform sampler2D colLocNoise;

varying vec3 WorldPos;
varying vec3 vertex_x;
varying float vertex_z;

uniform float wind_speed = 0.05;
uniform float wind_strength = 1.0;
uniform float wind_texture_tile_size = 20.0;
uniform float wind_vertical_strength = 0.1;
uniform vec2 wind_horizontal_direction = vec2(0.5,0.5);

vec2 panning(vec2 uv, vec2 scale, vec2 offset) {
	return uv = uv + offset * scale;
}

void vertex() {
	WorldPos = VERTEX;
	vertex_x = NODE_POSITION_WORLD;
	
	vec3 world_vert = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	vec2 normalized_wind_direction = normalize(wind_horizontal_direction);
	vec2 world_uv = world_vert.xz / wind_texture_tile_size + normalized_wind_direction * TIME * wind_speed;

	float displacement_affect = (1.0 - UV.y);
	float wind_noise_intensity = (texture(windNoise, world_uv).r - 0.5);

	vec2 vert_space_horizontal_dir = (inverse(MODEL_MATRIX) * vec4(wind_horizontal_direction, 0.0,0.0)).xy;
	vert_space_horizontal_dir = normalize(vert_space_horizontal_dir);
	
	vec3 bump_wind = vec3 (
		wind_noise_intensity * vert_space_horizontal_dir.x,
		1.0 - wind_noise_intensity,
		wind_noise_intensity * vert_space_horizontal_dir.y 
	);
	normalize(bump_wind);
	bump_wind *= vec3 (
		wind_strength,
		wind_vertical_strength,
		wind_strength
	);
	VERTEX += bump_wind * displacement_affect;
	
	// OLD WIND
	//// Creates the Wind and scrolls it based of the pos of grass blade in the world.
	//vec2 pos = NODE_POSITION_WORLD.xz + TIME;
	//vec3 preWind = texture(windNoise, pos * 0.05).xyz;
	//
	//// Making the wind based on a larger scale adding currents to the wind.
	//vec3 preGroupWind = texture(groupWindNoise, preWind.xz).xyz;
	//
	//// Locks movement to the top half of the blade of grass.
	//preGroupWind *= (1.0 - UV.y);
	//
	//// How far the blade will move from base.
	//vec3 wind = preGroupWind * vec3(0.3, 0.1, 0.3);
	//
	//// Apply the movement to the blade.
	//VERTEX += wind;
}

void fragment() {
	float surfaceColWeight = texture(colNoise, vec2(vertex_x.xz) / 100.0).r;
	float biomeColWeight = texture(colLocNoise, vec2(vertex_x.xz) / 50.0).r;
	
	vec3 grassBladeCol = mix(tipCol, baseCol, UV.y);
	
	vec3 surfaceCol = mix(mainCol, secondaryCol, surfaceColWeight);
	
	vec3 finalBiomeCol = mix(surfaceCol, biomeCol, biomeColWeight);
	
	vec3 grassCol = grassBladeCol * finalBiomeCol;
	
	ALBEDO = grassCol;
	ROUGHNESS = 0.0;
	NORMAL = vec3(0.0, 4.0, 0.0);
	NORMAL_MAP = vec3(0.0, 4.0, 0.0);
	
	//5aa551
	//548b00
}