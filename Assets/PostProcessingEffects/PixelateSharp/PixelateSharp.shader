Shader "RSPostProcessing/Pixelate Sharp"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_ScaleX ("Scale X", float) = 10
		_ScaleY ("Scale Y", float) = 10
	}

	SubShader 
	{
        Pass 
		{
            CGPROGRAM
            
            #pragma vertex vert_img
            #pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			float _ScaleX;
			float _ScaleY;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv     : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv     : TEXCOORD0;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
            
			float4 frag(v2f i) : SV_Target
			{
				float2 texel = _MainTex_TexelSize.xy * float2(_ScaleX, _ScaleY);
				float2 uv = i.uv.xy / texel;
				float3 sum = tex2D(_MainTex, floor(uv / 8) * 8 * texel).rgb;
				return fixed4(sum, 1);
			}

            ENDCG
        }
    }
}
