Shader "Hobscure/Deform"
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
			
			sampler2D _MainTex;
			sampler2D _TransformTex;
			float4 _MainTex_TexelSize;
			float2x2 _matric;

			fixed4 frag (v2f i) : SV_Target
			{
				float2 uv = i.uv / _ScreenParams.zw;
				
				fixed4 mask = tex2D(_TransformTex, uv);
				float sum = mask.x + mask.y + mask.z / 5. + 0.3;
				float t = sin(_Seed);
				_matric = float2x2(cos(t*sum), -sin(t*sum) + 2., sin(t*sum) + 2., cos(t*sum));
				float2 uv2 = mul(_matric, uv.xy *0.1);

				fixed4 mat = tex2D(_MainTex, uv2);

				return mat;
			}
			ENDCG
		}
	}
}
