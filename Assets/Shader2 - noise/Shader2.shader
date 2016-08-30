Shader "Hobscure/Noise"
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

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma enable_d3d11_debug_symbols
			
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

			float2 hash(float2 p)
			{
				p = float2(dot(p, float2(127.1, 311.7)),
					dot(p, float2(269.5, 183.3)));

				return -1.0 + 2.0*frac(sin(p)*43758.5453123 );
			}

			float noise(in float2 p)
			{
				float2 i = floor(p);
				float2 f = frac(p);

				float2 u = f*f*(3.0 - 2.0*f);

				return lerp(lerp(dot(hash(i + float2(0.0, 0.0)), f - float2(0.0, 0.0)),
					dot(hash(i + float2(1.0, 0.0)), f - float2(1.0, 0.0)), u.x),
					lerp(dot(hash(i + float2(0.0, 1.0)), f - float2(0.0, 1.0)),
					dot(hash(i + float2(1.0, 1.0)), f - float2(1.0, 1.0)), u.x), u.y);
			}

			
			sampler2D _MainTex;

			fixed4 frag (v2f i) : SV_Target
			{
				float2 p = i.uv / _ScreenParams.zw;

				float2 uv = p*float2(_ScreenParams.x / _ScreenParams.y, 1.0) * 20.;

				float f = 0.0;

				float2x2 m = float2x2(1.6, 1.2, -1.2, 1.6);

				f = 0.5000*noise(uv); 
				uv = mul(m, uv);
				f += 0.2500*noise(uv); 
				uv = mul(m, uv);
				f += 0.1250*noise(uv); 
				uv = mul(m, uv);
				f += 0.0625*noise(uv); 
				uv = mul(m,uv);

				f = 0.5 + 0.5*f;

				float4 color = float4(f, f, f, f);

				return color;
			}
			ENDCG
		}
	}
}
