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

			struct v2f
			{
				half3 worldNormal : TEXCOORD0;
				half3 objectNormal : TEXCOORD1;
				float4 pos : SV_POSITION;
			};

			float rand(float3 co)
			{
				return frac(sin(dot(co.xyz, float3(12.9898, 78.233, 45.5432))) * 43758.5453);
			}
			
			v2f vert(float4 vertex : POSITION, float3 normal : NORMAL)
			{
				v2f o;
				vertex *=  max(0.7, rand(vertex));
				o.pos = UnityObjectToClipPos(vertex);

				o.worldNormal = UnityObjectToWorldNormal(normal);
				o.objectNormal = (rand(normal) * 0.7 + (sin(_Time)*0.5 - 0.5));
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 nc = 0;
				nc.rgb = i.objectNormal*0.5 + 0.5;
				
				fixed4 color = dot(nc, _WorldSpaceLightPos0);
			
				return color * _LightColor0;
			}
			ENDCG
		}
	}
}
