shader_type spatial;

uniform float heightMap[65536];

void vertex() {
	VERTEX.y += heightMap[int(VERTEX.x * 256.0 + 128.0) + int(VERTEX.z * 256.0 + 128.0) * 256];
}