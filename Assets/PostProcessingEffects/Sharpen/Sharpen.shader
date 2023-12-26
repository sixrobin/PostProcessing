Shader "RSPostProcessing/Sharpen"
{
	Properties
	{
		_MainTex ("Main", 2D) = "white" {}
		_Size ("Size", Range(0.00005, 0.0008)) = 0.0001
		_Intensity ("Intensity", Range(0.5, 4)) = 2
	}
	
	SubShader
	{
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Size;
			float _Intensity;
			
			struct v2f
			{
				float4 pos        : SV_POSITION;
				float2 uv_MainTex : TEXCOORD0;
			};

			v2f vert(appdata_full v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			float4 frag(v2f i) : COLOR
			{
				float4 color = tex2D(_MainTex, i.uv_MainTex);
				// [TODO] Implement sharpen direction and rotate _Size by it.
				color -= tex2D(_MainTex, i.uv_MainTex + _Size) * 7 * _Intensity;
				color += tex2D(_MainTex, i.uv_MainTex - _Size) * 7 * _Intensity;
				return color;
			}
			
			ENDCG
		}
	}
}