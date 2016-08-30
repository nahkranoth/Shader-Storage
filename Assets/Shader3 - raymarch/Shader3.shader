Shader "Hobscure/RayMarch"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_TransformTex("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off 
		ZWrite Off 
		ZTest Always
		Blend SrcAlpha OneMinusSrcAlpha
		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma enable_d3d11_debug_symbols

			#define DISTANCE_THRESHOLD 0.001
			#define MAXIMUM_STEPS 90
			#define FAR_CLIP 40.0
			
			#include "UnityCG.cginc"

			uniform float _Seed; // declare the _Seed uniform float

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			float4 _MainTex_ST;

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				return o;
			}

			void rotateX(inout float3 p, float a) {
				float3 q = p;
				float c = cos(a);
				float s = sin(a);
				p.y = c * q.y - s * q.z;
				p.z = s * q.y + c * q.z;
			}

			float sdTorus(float3 rp, float2 t)
			{
				rotateX(rp, _Seed + 3.1415 / 2.);

				float2 q = float2(length(rp.xz) - t.x, rp.y);
				return length(q) - t.y;
			}

			float4 RayMarch(float3 rayCoordinate, float3 ro) {

				float d = 0.0; //distance marched
				float4 pc = float4(0., 0., 0., 0.); //pixel color

				for (int i = 0; i < MAXIMUM_STEPS; ++i) {

					float3 ray = ro + rayCoordinate * d; //ray position

					float ns = sdTorus(ray, float2(2., 0.3));
					d += ns;

					if (ns < DISTANCE_THRESHOLD) {
						pc = float4(1., 1., 1., 1.);
						break;
					}

					if (d > FAR_CLIP) {
						//miss as we've gone past rear clip
						break;
					}

				}
				return pc;
			}

			
			sampler2D _MainTex;

			fixed4 frag (v2f i) : SV_Target
			{
				float2 uv = i.uv / _ScreenParams.zw;
				uv = uv * 2.0 - 1.0;
				uv.x *= _ScreenParams.x / _ScreenParams.y;

				//coordinate
				float3 rayCoordinate = normalize(float3(uv.x, uv.y, 2.));
				float3 ro = float3(0., 0., -20.);

				fixed4 mat = tex2D(_MainTex, uv);

				fixed4 rm = RayMarch(rayCoordinate, ro);

				return rm;
			}
			ENDCG
		}
	}
}
