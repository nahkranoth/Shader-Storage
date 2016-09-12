Shader "Hobscure/Volumetric Clouds 3"
{
	Properties
	{
		// How many iterations we should step through space
		_Iterations("Iterations", Range(0, 200)) = 100
		// How long through space we should step
		_ViewDistance("View Distance", Range(0, 5)) = 2
		// Essentially the background color
		_SkyColor("Sky Color", Color) = (0.176, 0.478, 0.871, 1)
		// Cloud color
		_CloudColor("Cloud Color", Color) = (1, 1, 1, 1)
		// How dense our clouds should be
		_CloudDensity("Cloud Density", Range(0, 1)) = 0.5

		// Note that the longer your view distance is, the more steps are required. And the smaller your clouds are, the bigger a render target is needed.
	}
	SubShader
	{
		Pass
		{
			// Ignore the destination color and print the new one.
			Blend SrcAlpha Zero

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			// Global properties
			sampler2D _NoiseOffsets;
			float3 _CamPos;
			float3 _CamRight;
			float3 _CamUp;
			float3 _CamForward;
			float _AspectRatio;
			float _FieldOfView;

			// Local properties
			int _Iterations;
			float3 _SkyColor;
			float4 _CloudColor;
			float _ViewDistance;
			float _CloudDensity;
			uniform float _Seed; // declare the _Seed uniform float

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata_base  v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord;
				return o;
			}

			void rotateX(inout float3 p, float a) {
				float3 q = p;
				float c = cos(a);
				float s = sin(a);
				p.y = c * q.y - s * q.z;
				p.z = s * q.y + c * q.z;
			}

			void rotateY(inout float3 p, float a) {
				float3 q = p;
				float c = cos(a);
				float s = sin(a);
				p.x = c * q.x + s * q.z;
				p.z = -s * q.x + c * q.z;
			}

			void rotateZ(inout float3 p, float a) {
				float3 q = p;
				float c = cos(a);
				float s = sin(a);
				p.x = c * q.x - s * q.y;
				p.y = s * q.x + c * q.y;
			}

			// Noise function by Inigo Quilez - https://www.shadertoy.com/view/4sfGzS
			float noise(float3 x) { 
				x *= 4.0; 
				float3 p = floor(x); 
				float3 f = frac(x); 
				f = f*f*(3.0 - 2.0*f); 
				float2 uv = (p.xy + float2(37.0, 17.0)*p.z) + f.xy; 
				float2 rg = tex2D(_NoiseOffsets, (uv + 0.5) / 256.0).yx; 
				return lerp(rg.x, rg.y, f.z); 
			}

			// This function is the actual noise function we are going to be using.
			// The more octaves you give it, the more details we'll get in our noise.
			float fbm(float3 pos, int octaves) { 
				float f = 0.; 
				for (int i = 0; i < octaves; i++) { 
					f += noise(pos) / pow(2, i + 1); pos *= 2.01; 
				} 
				f /= 1 - 1 / pow(2, octaves + 1); 
				return f; 
			}

			float3 centerPoint = float3(0.5, 0.5, 0.5);

			fixed4 frag(v2f i) : SV_Target
			{
				float2 uv = (i.uv - 0.5) * _FieldOfView;
				uv.x *= _AspectRatio;
				float3 ray = _CamUp * uv.y + _CamRight * uv.x + _CamForward;
				float3 pos = _CamPos * 0.4;

				// So now we have a position, and a ray defined for our current fragment, and we know from earlier in this article that it matches the field of view and aspect ratio of the camera. And we can now start iterating and creating our clouds. 
				// We will not be ray-marching twoards any distance field in this example. So the following code should be much easier to understand.
				// pos is our original position, and p is our current position which we are going to be using later on.
				float3 p = pos;
				// For each iteration, we read from our noise function the density of our current position, and adds it to this density variable.
				float density = 0;
				float dis;
				float3 clr;

				for (float i = 0; i < _Iterations; i++)
				{
					// f gives a number between 0 and 1.
					// We use that to fade our clouds in and out depending on how far and close from our camera we are.
					float f = i / _Iterations;

					dis = 1 - distance(p, centerPoint) * 0.36;

					float alpha = smoothstep(0, _Iterations * 0.2, i) * (1 - f) * dis;

					float denseClouds = smoothstep(1., 0.22, fbm(p, 25));

					// Note that I smoothstep again to tell which range of the noise we should consider clouds.
					// Here we add our result to our density variable
					density += (denseClouds * 0.52) * alpha;
					// And then we move one step further away from the camera.
					p = pos + ray * f * _ViewDistance;

					rotateX(p, _Seed * 0.1);
					rotateY(p, _Seed * 0.2 + p.y);

				}

				float red = (density  / _Iterations) * 30;
				float green = 0;
				float blue = (density / _Iterations) * 70;
				float3 color = float3(red, green, blue);

				return fixed4(color, 1);
			}
			ENDCG
		}
	}
}