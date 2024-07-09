shader_type spatial;

uniform sampler2D noise;
uniform sampler2D noise2;
uniform sampler2D waterNoise;

const float hallo = 0.48;

void vertex() {
	float test1 = texture(noise, VERTEX.xz).r * 0.25;
	float test2 = texture(noise2, VERTEX.xz).r * 0.5;
	float water = texture(waterNoise, VERTEX.xz).r * 0.25;
	
	float dist = max(abs(VERTEX.x), abs(VERTEX.z));
	
	if (abs(VERTEX.x) > water + 0.25 || abs(VERTEX.z) > water + 0.25) {
		VERTEX.y = min(max(-dist, hallo), 0.08) - 0.1;
	} 
	
	if (dist > hallo) {
		VERTEX.y += min(-dist + hallo + 0.1, mix(test1, test2, 0.5));
	} else {
		VERTEX.y += mix(test1, test2, 0.5); 
	}
}

