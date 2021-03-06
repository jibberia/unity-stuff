﻿Shader "Unlit/Aqua"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{

GLSLPROGRAM
#version 330
#ifdef VERTEX

// Input vertex attributes
in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec3 vertexNormal;
in vec4 vertexColor;

// Input uniform values
uniform mat4 mvpMatrix;
uniform mat4 modelMatrix;
uniform vec2 transition;
uniform vec2 aspect;

// Output vertex attributes (to fragment shader)
out vec2 fragTexCoord;
out vec4 fragColor;
out vec3 vNormal;

// NOTE: Add here your custom variables 

void main()
{
    // Send vertex attributes to fragment shader
    fragTexCoord = vertexTexCoord;
    fragColor = vertexColor;

    mat3 normalMatrix = transpose(inverse(mat3(modelMatrix)));
    vNormal = normalize(normalMatrix * vertexNormal);

    // Calculate final vertex position
    gl_Position = mvpMatrix*vec4(vertexPosition, 1.0);
}

#endif

#ifdef FRAGMENT

precision highp float;
precision mediump int;

uniform sampler2D _MainTex;

// varying vec2 textureCoordinate;
// uniform sampler2D inputImageTexture;
in vec2 fragTexCoord;
in vec4 fragColor;
in vec3 vNormal;

// uniform int hypno_instructionIndex;
// uniform float hypno_compositionTime;
// uniform float hypno_instructionTime;
#define hypno_instructionIndex 0
#define hypno_compositionTime 0.0
#define hypno_instructionTime 0.0

// #define resolution textureCoordinate
// #define texture inputImageTexture
#define resolution fragTexCoord
// #define texture _MainTex

out vec4 finalColor;

#define SPEED (0.75 * (floor(hypno_instructionTime * 2.0) + 1.0))
#define DENSITY (hypno_instructionIndex / 2 + 1)
#define INTENSITY (0.3 - 0.25 * hypno_instructionTime)
#define TURBULENCE (0.5 * float(hypno_instructionIndex / 4+ 1))


vec3 mod289 (vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}
vec2 mod289 (vec2 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}
vec3 permute (vec3 x) {
  return mod289(((x*34.0)+1.0)*x);
}

float snoise (vec2 v) {
  const vec4 C = vec4 (0.211324865405187,  // (3.0-sqrt(3.0))/6.0",
                       0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                       -0.577350269189626,  // -1.0 + 2.0 * C.x"
                       0.024390243902439); // 1.0 / 41.0
    vec2 i  = floor (v + dot (v, C.yy));
    vec2 x0 = v - i + dot (i, C.xx);
    vec2 i1;
    i1 = (x0.x > x0.y) ? vec2 (1.0, 0.0) : vec2 (0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    i = mod289 (i); // Avoid truncation effects in permutation"
    vec3 p = permute (permute (i.y + vec3 (0.0, i1.y, 1.0)) + i.x + vec3 (0.0, i1.x, 1.0));
    vec3 m = max (0.5 - vec3 (dot( x0,x0), dot (x12.xy, x12.xy), dot (x12.zw, x12.zw)), 0.0);
    m = m * m;
    m = m * m;
    vec3 x = 2.0 * fract (p * C.www) - 1.0;
    vec3 h = abs (x) - 0.5;
    vec3 ox = floor (x + 0.5);
    vec3 a0 = x - ox;
    m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);
    vec3 g;
    g.x  = a0.x * x0.x + h.x * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 65.0 * dot (m, g);
}

float fbm (in vec2 st) {
  float value = 0.0;
  float amplitud = .5;
  float frequency = 0.;

  for (int i = 0; i < DENSITY ; i++) {
      value += amplitud * snoise(st);
      st *= 2.;
      amplitud *= .5;
  }
  return clamp(0.0,1.0,value);
}


float fluid( vec2 p ) {
  vec2 q = vec2( fbm( p + vec2(0.0,0.0) - SPEED * 0.3 * hypno_instructionTime),
                 fbm( p + vec2(0.5,1.3) + SPEED *  0.3 * hypno_instructionTime) );

  vec2 r = vec2( fbm( p + 4.0 *  q + vec2(1.7,9.2) + SPEED *  0.2 * hypno_instructionTime),
                 fbm( p + 4.0 * q + vec2(8.3,2.8) - SPEED * 0.2 * hypno_instructionTime) );

  return fbm( p + 4.0 * r );
}


vec4 flow(float intensity, float turbulence) {

  vec2 uv = resolution;

  vec2 coords = vec2(1.0, 5.0) * uv * 0.75 * turbulence * vec2(1.0, 0.5) - 0.5 * float(hypno_instructionIndex + 1);

  float warp = 3.0 * fluid(coords);

  vec4 camera = texture(_MainTex, uv + intensity * vec2(warp/2.0));

  vec3 a = vec3(180.0) / 255.0; //100
  vec3 b = vec3(154.0) / 255.0; //66
  vec3 c = vec3(80.0) / 255.0; //33
  vec3 d = vec3(30.0) / 255.0; //100

  vec3 final;

  warp = clamp(0.0, 1.0, warp);
  if (warp >= 2.5 / 3.0) final = mix(a, vec3(1.0), (warp - (2.5 / 3.0)) * 6.0);
  else if ( warp >= 2.0 / 3.0 ) final = mix(b, a, (warp - (2.0 / 3.0)) * 6.0);
  else if ( warp >= 1.0 / 3.0) final = mix(c, b, (warp - (1.0 / 3.0)) * 3.0);

  else final = mix(d, c, warp * 3.0);

  float blend = 0.75 * (1.0 - hypno_instructionTime);

  return vec4(camera.rgb + blend * camera.rgb * final.rgb, 1.0);
}




void main() {

  vec4 final = flow(INTENSITY, TURBULENCE);
//   finalColor = final;
  gl_FragColor = final;

}

#endif
ENDGLSL

			// CGPROGRAM
			// #pragma vertex vert
			// #pragma fragment frag
			// // make fog work
			// #pragma multi_compile_fog
			
			// #include "UnityCG.cginc"

			// struct appdata
			// {
			// 	float4 vertex : POSITION;
			// 	float2 uv : TEXCOORD0;
			// };

			// struct v2f
			// {
			// 	float2 uv : TEXCOORD0;
			// 	UNITY_FOG_COORDS(1)
			// 	float4 vertex : SV_POSITION;
			// };

			// sampler2D _MainTex;
			// float4 _MainTex_ST;
			
			// v2f vert (appdata v)
			// {
			// 	v2f o;
			// 	o.vertex = UnityObjectToClipPos(v.vertex);
			// 	o.uv = TRANSFORM_TEX(v.uv, _MainTex);
			// 	UNITY_TRANSFER_FOG(o,o.vertex);
			// 	return o;
			// }
			
			// fixed4 frag (v2f i) : SV_Target
			// {
			// 	// sample the texture
			// 	fixed4 col = tex2D(_MainTex, i.uv);
			// 	// apply fog
			// 	UNITY_APPLY_FOG(i.fogCoord, col);
			// 	return col;
			// }
			// ENDCG
		}
	}
}
