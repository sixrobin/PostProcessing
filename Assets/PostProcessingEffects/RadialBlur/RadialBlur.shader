Shader "RSPostProcessing/Radial Blur"
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "" {}
		_Samples ("Samples", Int) = 0
		_Strength ("Strength", Range(0, 1)) = 0
		_CenterX ("Center X", Float) = 0.5
		_CenterY ("Center Y", Float) = 0.5
	}

	Subshader 
	{
		Pass 
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			struct v2f 
			{
				float4 position : SV_POSITION;
				float2 uv       : TEXCOORD0;
			};

			sampler2D _MainTex;
			int _Samples;
			fixed _Strength;
			fixed _CenterX;
			fixed _CenterY;
			
			v2f vert(appdata_img v) 
			{
				v2f o;
				o.position = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord.xy;
				return o;
			} 
			
			fixed4 frag(v2f i) : SV_Target 
			{
				if (_Samples == 1)
					return fixed4(tex2D(_MainTex, i.uv));
				
				float3 sum = float3(0, 0, 0);

				half2 center = half2(_CenterX, _CenterY);
				half2 uv_center = half2(i.uv - center);
				half center_distance = length(uv_center);
				
				for (int s = 0; s < _Samples; s++) 
				{ 
					float scale = 1 - _Strength * center_distance * (s / float(_Samples - 1));
					sum += tex2D(_MainTex, uv_center * scale + center).rgb; 
				} 

				sum /= _Samples; 

				return fixed4(sum, 1);
			}
			
			ENDCG
		} 
	}
}
