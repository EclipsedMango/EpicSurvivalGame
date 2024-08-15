shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_toon, specular_toon, depth_prepass_alpha;

uniform vec3 albedo : source_color;
uniform vec3 albedo2 : source_color;
uniform vec3 albedo3 : source_color;

uniform sampler2D leaves;
uniform sampler2D WindNoise;
uniform sampler2D thing;

uniform float panningScale = 0.1;

uniform float SubSurfDistortion: hint_range(0.0, 5.0) = 1.0;
uniform vec3 SubSurfTint: source_color;
uniform float SubSurfBrightness: hint_range(0.0, 10.0) = 3.0;
uniform float SubSurfCutoff: hint_range(0.0, 1.0) = 0.5;
uniform float SubSurfSmoothness: hint_range(0.0, 1.0) = 0.05;
uniform sampler2D SubSurfTexture: source_color, hint_default_white;

uniform float ToonRampOffset: hint_range(0.0, 1.0) = 0.5;
uniform float ToonRampSmoothness: hint_range(0.0, 1.0) = 0.05;
uniform vec3 ToonRampTinting: source_color;

varying vec3 WorldPos;
varying vec3 LocalPos;

vec2 panning(vec2 uv, vec2 scale, vec2 offset) {
	return uv = uv + offset * scale;
}

void vertex() {
	vec2 offset = NODE_POSITION_WORLD.xy + TIME;
	vec2 objectPanning = panning(UV, vec2(panningScale), offset);
	vec4 windPos = texture(WindNoise, objectPanning);
	
	float windDir = 1.0 - UV.y;
	
	vec3 wind = (windPos.xyz * windDir) * vec3(0.3, 0.1, 0.3);
	
	LocalPos = VERTEX;
	
	VERTEX = VERTEX + wind;
	
	vec3 view = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	WorldPos = vec3(view);
}

void fragment() {
	float colWeight = LocalPos.y * -2.5;
	colWeight = 1.0 - colWeight;
	
	vec3 mixedCol = mix(albedo, albedo2, colWeight);
	
	vec4 leavesTex = texture(leaves, UV);
	ALPHA = leavesTex.a;
	
	vec3 col = mixedCol * leavesTex.xyz;
	
	vec2 texSize = LocalPos.yz * 0.0;
	
	vec4 myFriend = texture(thing, texSize);
	
	vec3 colPos = myFriend.xyz * (1.0 - UV.y);
	vec3 secCol = albedo3 * colPos;
	
	ALBEDO = mix(col, secCol, 0.5);
}

void light() {
	// Diffuse Shading
	float diffuseShading = dot(WorldPos.xyz, LIGHT) * 1.5;
	float toonRamp = smoothstep(ToonRampOffset, ToonRampOffset + ToonRampSmoothness, diffuseShading);
	
	// Shadows
	toonRamp *= ATTENUATION * 1.5;
	
	vec3 toonRampOutput = LIGHT_COLOR * toonRamp;
	vec3 ambientLightOutput = ALBEDO * ToonRampTinting;
	DIFFUSE_LIGHT += clamp((toonRampOutput - ambientLightOutput), vec3(0.0), vec3(1.0));
	

	float subSurfBack = dot(VIEW, -(LIGHT - LocalPos.xyz * SubSurfDistortion));
	float subSurfFront = dot(VIEW, LIGHT * LocalPos.xyz * SubSurfDistortion);
	subSurfBack = max(subSurfBack, 0.0);
	subSurfFront = max(subSurfFront, 0.0);
	
	float subSurfScattering = smoothstep(SubSurfCutoff, SubSurfCutoff + SubSurfSmoothness, subSurfBack + subSurfFront); 
	
	vec3 subSurfColor = SubSurfTint * texture(SubSurfTexture, UV).rgb;
	DIFFUSE_LIGHT += subSurfScattering * SubSurfBrightness * subSurfColor;
	
	SPECULAR_LIGHT = ambientLightOutput;
}