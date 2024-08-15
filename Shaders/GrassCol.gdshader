shader_type spatial;
render_mode blend_mix, cull_disabled, diffuse_toon, specular_toon, depth_prepass_alpha;

uniform vec3 tipCol: source_color;
uniform vec3 baseCol: source_color;
uniform vec3 mainCol: source_color;
uniform vec3 secondaryCol: source_color;

uniform sampler2D groupWindNoise;
uniform sampler2D windNoise;
uniform sampler2D colNoise;

varying vec3 WorldPos;
varying vec3 vertex_x;
varying float vertex_z;

vec2 panning(vec2 uv, vec2 scale, vec2 offset) {
	return uv = uv + offset * scale;
}

void vertex() {
	WorldPos = VERTEX;
	vertex_x = NODE_POSITION_WORLD;
	
	// Creates the Wind and scrolls it based of the pos of grass blade in the world.
	vec2 pos = NODE_POSITION_WORLD.xz + TIME;
	vec3 preWind = texture(windNoise, pos * 0.05).xyz;
	
	// Making the wind based on a larger scale adding currents to the wind.
	vec3 preGroupWind = texture(groupWindNoise, preWind.xz).xyz;
	
	// Locks movement to the top half of the blade of grass.
	preGroupWind *= (1.0 - UV.y);
	
	// How far the blade will move from base.
	vec3 wind = preGroupWind * vec3(0.3, 0.1, 0.3);
	
	// Apply the movement to the blade.
	VERTEX += wind;
}

void fragment() {
	float surfaceColWeight = texture(colNoise, vec2(vertex_x.xz) / 100.0).r;
	
	vec3 grassBladeCol = mix(tipCol, baseCol, UV.y);
	
	vec3 surfaceCol = mix(mainCol, secondaryCol, surfaceColWeight);
	
	vec3 finalGrassCol = grassBladeCol * surfaceCol;
	
	ALBEDO = finalGrassCol;
	ROUGHNESS = 0.0;
	NORMAL = vec3(0.0, 4.0, 0.0);
	NORMAL_MAP = vec3(0.0, 4.0, 0.0);
	
	//5aa551
	//548b00
}