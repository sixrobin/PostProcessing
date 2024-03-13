Shader "RSPostProcessing/Sobel Outline"
{
    Properties
    {
    	_MainTex ("Main Tex", 2D) = "white" {}
    	
	    _OutlineThickness ("Outline Thickness", Float) = 1
	    _OutlineColor ("Outline Color", Color) = (0, 0, 0, 0)

	    _OutlineDepthMultiplier ("Outline Depth Multiplier", Float) = 1
	    _OutlineDepthBias ("Outline Depth Bias", Float) = 1
    	
	    _OutlineNormalMultiplier ("Outline Normal Multiplier", Float) = 1
	    _OutlineNormalBias ("Outline Normal Bias", Float) = 1
    }
    
    SubShader
    {
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature DEBUG_NONE DEBUG_DEPTH DEBUG_NORMAL
            
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

			float _OutlineThickness;
            float4 _OutlineColor;

            float _OutlineDepthMultiplier;
            float _OutlineDepthBias;
            float _OutlineNormalMultiplier;
            float _OutlineNormalBias;
            
			float computeSobelDepth(float2 uv, float2 offset)
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

            float4 computeSobelNormal(float2 uv, float3 offset)
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
				float4 screenColor = tex2D(_MainTex, i.uv);

				float sobelDepth = saturate(pow(saturate(computeSobelDepth(i.uv, offset)) * _OutlineDepthMultiplier, _OutlineDepthBias));
				#ifdef DEBUG_DEPTH
					return fixed4(sobelDepth.xxx, 1);
				#endif
				
			    float3 sobelNormalVector = computeSobelNormal(i.uv.xy, offset).rgb;
				float sobelNormal = sobelNormalVector.x + sobelNormalVector.y + sobelNormalVector.z;
				sobelNormal = pow(sobelNormal * _OutlineNormalMultiplier, _OutlineNormalBias);
				#ifdef DEBUG_NORMAL
					return fixed4(sobelNormalVector, 1);
				#endif
				
				float outline = saturate(max(sobelDepth, sobelNormal));
				
				return lerp(screenColor, _OutlineColor, outline);
			}
            
            ENDCG
        }
    }
}
