Shader "Hobscure/Shader10 - Normals"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			uniform float _SeedTimer; // declare the _Seed uniform float

			struct v2f
			{

				half3 worldNormal : TEXCOORD0;
				half3 objectNormal : TEXCOORD1;

				float4 uv : TEXCOORD2;
				float4 pos : SV_POSITION;
			};

			float rand(float3 co)
			{
				return frac(sin(dot(co.xyz, float3(12.9898, 78.233, 45.5432))) * 43758.5453);
			}

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert(float4 vertex : POSITION, float3 normal : NORMAL)
			{
				v2f o;
				vertex *=  max(0.6, rand(vertex + _SeedTimer));
				o.pos = UnityObjectToClipPos(vertex);
				o.uv = vertex;
				o.worldNormal = UnityObjectToWorldNormal(normal);
				o.objectNormal = (rand(normal) * 0.7 + (sin(_Time)*0.5 - 0.5));
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 nc = 0;
				nc.rgb = i.objectNormal*0.5 + 0.5;

				float tex = tex2D(_MainTex, i.uv * 24. + _Time).rgb;

				fixed4 color = dot(nc, _WorldSpaceLightPos0);
			
				return color * _LightColor0 * tex;
			}
			ENDCG
		}
	}
}
