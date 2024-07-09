shader_type spatial;

uniform float heightMap[65536];

uniform vec3 topColor: source_color;
uniform vec3 midColor: source_color;
uniform vec3 bottomColor: source_color;

uniform float min_rock_slope: hint_range(0., 1., 0.01) = 0.5;
uniform float max_grass_slope: hint_range(0., 1., 0.01) = 0.9;
uniform float min_rockgrass_height = -8.0;
uniform float max_sand_height = -6.0;

varying float normal_y;
varying float vertex_y;


void vertex() {
	float colHeight = VERTEX.y * 256.0;
	COLOR = vec4(mix(topColor, bottomColor, colHeight), 1.0); 
	
	normal_y = NORMAL.y;
	vertex_y = VERTEX.y;
}

void fragment() {
	//Weights
	float rock_grass_weight = normal_y;
	float sand_rockgrass_weight = vertex_y;
	
	//Calculating Rock/Grass Weight
	rock_grass_weight = max(min_rock_slope, rock_grass_weight);
	rock_grass_weight = min(max_grass_slope, rock_grass_weight);
	rock_grass_weight -= min_rock_slope;
	rock_grass_weight /= max_grass_slope - min_rock_slope;
	
	//Calculating Sand/RockGrass Weight
	sand_rockgrass_weight = max(min_rockgrass_height, sand_rockgrass_weight);
	sand_rockgrass_weight = min(max_sand_height, sand_rockgrass_weight);
	sand_rockgrass_weight -= min_rockgrass_height;
	sand_rockgrass_weight /= max_sand_height - min_rockgrass_height;
	
	//Mixing and Assigning Albedo
	vec3 rockgrass_albedo = mix(midColor, topColor, rock_grass_weight);
	ALBEDO = mix(bottomColor, rockgrass_albedo, sand_rockgrass_weight);
}