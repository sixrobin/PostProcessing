Shader "RSPostProcessing/Pixelate Blurred"
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
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			sampler2D _MainTex;
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

			v2f vert(const appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 color;
				
				if (_ScaleX > 1 || _ScaleY > 1)
				{
					float2 pixel_size = 1.0 / float2(_ScreenParams.xy);
					float2 block_size = pixel_size * float2(_ScaleX, _ScaleY);
					
					float2 current_block = float2
					(
						floor(i.uv.x / block_size.x) * block_size.x,
						floor(i.uv.y / block_size.y) * block_size.y
					);
					
					color = tex2D(_MainTex, current_block + block_size * 0.5);
					color += tex2D(_MainTex, current_block + float2(block_size.x * 0.25, block_size.y * 0.25));
					color += tex2D(_MainTex, current_block + float2(block_size.x * 0.5, block_size.y * 0.25));
					color += tex2D(_MainTex, current_block + float2(block_size.x * 0.25 * 3, block_size.y * 0.25));
					color += tex2D(_MainTex, current_block + float2(block_size.x * 0.25, block_size.y * 0.5));
					color += tex2D(_MainTex, current_block + float2(block_size.x * 0.25 * 3, block_size.y * 0.5));
					color += tex2D(_MainTex, current_block + float2(block_size.x * 0.25, block_size.y * 0.25 * 3));
					color += tex2D(_MainTex, current_block + float2(block_size.x * 0.5, block_size.y * 0.25 * 3));
					color += tex2D(_MainTex, current_block + float2(block_size.x * 0.25 * 3, block_size.y * 0.25 * 3));
					color *= 0.1111;
				}
				else
				{
					color = tex2D(_MainTex, i.uv);
				}
				
				return color;
			}

			ENDCG
		}
	}
}
