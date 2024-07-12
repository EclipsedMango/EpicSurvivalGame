shader_type spatial;

uniform float heightMap[65536];

uniform sampler2D noise_t;

uniform vec3 topColor: source_color;
uniform vec3 secondaryTopColor: source_color;
uniform vec3 midColor: source_color;
uniform vec3 bottomColor: source_color;

uniform float min_rock_slope: hint_range(0., 1., 0.01) = 0.5;
uniform float max_grass_slope: hint_range(0., 1., 0.01) = 0.9;
uniform float min_rockgrass_height = -8.0;
uniform float sand_height = 0.0;
uniform float sand_fade_distance = 1.0;

varying float normal_y;
varying float vertex_y;
varying float vertex_x;
varying float vertex_z;

void vertex() {
	float colHeight = VERTEX.y * 256.0;
	COLOR = vec4(mix(topColor, bottomColor, colHeight), 1.0); 
    
	normal_y = NORMAL.y;
	vertex_y = VERTEX.y;
	vertex_x = VERTEX.x;
	vertex_z = VERTEX.z;
}

void fragment() {
	float hallo = texture(noise_t, vec2(vertex_x, vertex_z) * 10.0).r;
	
	//Weights
	float rock_grass_weight = normal_y;

	//Calculating Rock/Grass Weight
	rock_grass_weight = max(min_rock_slope, rock_grass_weight);
	rock_grass_weight = min(max_grass_slope, rock_grass_weight);
	rock_grass_weight -= min_rock_slope;
	rock_grass_weight /= max_grass_slope - min_rock_slope;
    
	float sand_rockgrass_weight = vertex_y * sand_fade_distance + sand_height;
	sand_rockgrass_weight = clamp(sand_rockgrass_weight, 0.0, 1.0);
    
	//Mixing and Assigning Albedo
	vec3 mixed_surface_color = mix(topColor, secondaryTopColor, hallo);
	vec3 rockgrass_albedo = mix(midColor, mixed_surface_color, rock_grass_weight);
	ALBEDO = mix(bottomColor, rockgrass_albedo, sand_rockgrass_weight);
}