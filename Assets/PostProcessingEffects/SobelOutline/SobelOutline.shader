Shader "RSPostProcessing/Sobel Outline"
{
    Properties
    {
    	_MainTex ("Main Tex", 2D) = "white" {}
	    _OutlineThickness ("Outline Thickness", Float) = 1
	    _OutlineDepthMultiplier ("Outline Depth Multiplier", Float) = 1
	    _OutlineDepthBias ("Outline Depth Bias", Float) = 1
    	_OutlineColor ("Outline Color", Color) = (0, 0, 0, 0)
    }
    
    SubShader
    {
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

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

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            sampler2D _CameraGBufferTexture2;
            float _OutlineDepthMultiplier;
            float _OutlineDepthBias;
			float _OutlineThickness;
            float4 _OutlineColor;

			float sobel(float2 uv, float2 offset)
            {
				float4 hr = float4(0, 0, 0, 0);
				float4 vt = float4(0, 0, 0, 0);
				
				hr += tex2D(_CameraDepthTexture, uv + float2(-1, -1) * offset) *  1;
				hr += tex2D(_CameraDepthTexture, uv + float2( 1, -1) * offset) * -1;
				hr += tex2D(_CameraDepthTexture, uv + float2(-1,  0) * offset) *  2;
				hr += tex2D(_CameraDepthTexture, uv + float2( 1,  0) * offset) * -2;
				hr += tex2D(_CameraDepthTexture, uv + float2(-1,  1) * offset) *  1;
				hr += tex2D(_CameraDepthTexture, uv + float2( 1,  1) * offset) * -1;
				
				vt += tex2D(_CameraDepthTexture, uv + float2(-1, -1) * offset) *  1;
				vt += tex2D(_CameraDepthTexture, uv + float2( 0, -1) * offset) *  2;
				vt += tex2D(_CameraDepthTexture, uv + float2( 1, -1) * offset) *  1;
				vt += tex2D(_CameraDepthTexture, uv + float2(-1,  1) * offset) * -1;
				vt += tex2D(_CameraDepthTexture, uv + float2( 0,  1) * offset) * -2;
				vt += tex2D(_CameraDepthTexture, uv + float2( 1,  1) * offset) * -1;
				
				return sqrt(hr * hr + vt * vt);
			}

            float4 SobelSampleNormal(float2 uv, float3 offset)
			{
			    float4 pixelCenter = tex2D(_CameraGBufferTexture2, uv);
			    float4 pixelLeft = tex2D(_CameraGBufferTexture2, uv - offset.xz);
			    float4 pixelRight = tex2D(_CameraGBufferTexture2, uv + offset.xz);
			    float4 pixelUp = tex2D(_CameraGBufferTexture2, uv + offset.zy);
			    float4 pixelDown = tex2D(_CameraGBufferTexture2, uv - offset.zy);
			    
			    return abs(pixelLeft - pixelCenter) + abs(pixelRight - pixelCenter) + abs(pixelUp - pixelCenter) + abs(pixelDown - pixelCenter);
			}
            
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
            
			float4 frag(v2f i) : SV_Target
			{
				float3 offset = float3((1.0 / _ScreenParams.x), (1.0 / _ScreenParams.y), 0.0) * _OutlineThickness;
			    float3 sobelNormalVec = SobelSampleNormal(i.uv.xy, offset).rgb;
				float sobelNormal = sobelNormalVec.x + sobelNormalVec.y + sobelNormalVec.z;
				sobelNormal = pow(sobelNormal * _OutlineDepthMultiplier, _OutlineDepthBias);
				return float4(sobelNormal.xxx, 1);
				
				// float2 offset = float2(1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y) * _OutlineThickness;
				// float sobelDepth = saturate(pow(saturate(sobel(i.uv, offset)) * _OutlineDepthMultiplier, _OutlineDepthBias));
				// float4 color = tex2D(_MainTex, i.uv);
				// return lerp(color, _OutlineColor, sobelDepth);
			}
            
            ENDCG
        }
    }
}
