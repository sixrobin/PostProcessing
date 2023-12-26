Shader "RSPostProcessing/Glitch"
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_DispTex ("Base (RGB)", 2D) = "bump" {}
		_Intensity ("Glitch Intensity", Range(0.1, 1.0)) = 1
		_ColorIntensity ("Color Bleed Intensity", Range(0.1, 1.0)) = 0.2
	}

	SubShader
	{
		Pass
		{
			ZTest Always
			Cull Off
			ZWrite Off
			
			Fog
			{
				Mode off
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest 
			
			#include "UnityCG.cginc"
			
			uniform sampler2D _MainTex;
			uniform sampler2D _DispTex;
			float _Intensity;
			float _ColorIntensity;

			fixed4 direction;

			float filter_radius;
			float flip_up;
			float flip_down;
			float displace;
			float scale;
			
			struct v2f
			{
				float4 pos : POSITION;
				float2 uv  : TEXCOORD0;
			};
			
			v2f vert(appdata_img v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord.xy;
				return o;
			}
			
			half4 frag(v2f i) : COLOR
			{
				half4 normal = tex2D (_DispTex, i.uv.xy * scale);
				
				i.uv.y -= (1 - (i.uv.y + flip_up)) * step(i.uv.y, flip_up) + (1 - (i.uv.y - flip_down)) * step(flip_down, i.uv.y);
				i.uv.xy += (normal.xy - 0.5) * displace * _Intensity;
				
				half4 color = tex2D(_MainTex,  i.uv.xy);
				half4 red_color = tex2D(_MainTex, i.uv.xy + direction.xy * 0.01 * filter_radius * _ColorIntensity);
				half4 green_color = tex2D(_MainTex, i.uv.xy - direction.xy * 0.01 * filter_radius * _ColorIntensity);

				color += fixed4(red_color.rbg, 1) * step(filter_radius, -0.001);
				color *= 1 - 0.5 * step(filter_radius, -0.001);

				color += fixed4(green_color.gbr, 1) * step(0.001, filter_radius);
				color *= 1 - 0.5 * step(0.001, filter_radius);
				
				return color;
			}
			
			ENDCG
		}
	}

	Fallback off
}