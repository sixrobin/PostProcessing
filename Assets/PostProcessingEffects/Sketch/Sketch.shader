Shader "RSPostProcessing/Sketch"
{
    Properties
    {
    	_MainTex ("Main Tex", 2D) = "white" {}
    	_MainTexDistortion ("Main Tex Distortion", 2D) = "black" {}
    	_MainTexDistortionIntensity ("Main Tex Distortion Intensity", Float) = 1
    	
    	_Posterization ("Posterization", Float) = 256
    	_Crosshatches ("Crosshatches", 2DArray) = "" {}
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

            sampler2D _CameraDepthTexture;
            sampler2D _CameraGBufferTexture2;
            
            sampler2D _MainTex;
            sampler2D _MainTexDistortion;
            float4 _MainTexDistortion_ST;
            float _MainTexDistortionIntensity;
            
            float _Posterization;
            UNITY_DECLARE_TEX2DARRAY(_Crosshatches);
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
				float2 uv = i.uv;
				float distortion = tex2D(_MainTexDistortion, i.uv * _MainTexDistortion_ST.xy + _MainTexDistortion_ST.zw);
				distortion = (distortion - 0.5) * 2 * _MainTexDistortionIntensity;
				uv += distortion;

				float depth = tex2D(_CameraDepthTexture, uv);
				if (depth == 0)
					return _OutlineColor;

				float3 offset = float3((1.0 / _ScreenParams.x), (1.0 / _ScreenParams.y), 0.0) * _OutlineThickness;
				float4 screenColor = tex2D(_MainTex, uv);

				// Sobel outline.
				float sobelDepth = saturate(pow(saturate(computeSobelDepth(uv, offset)) * _OutlineDepthMultiplier, _OutlineDepthBias));
			    float3 sobelNormalVector = computeSobelNormal(uv.xy, offset).rgb;
				float sobelNormal = sobelNormalVector.x + sobelNormalVector.y + sobelNormalVector.z;
				sobelNormal = pow(sobelNormal * _OutlineNormalMultiplier, _OutlineNormalBias);
				float outline = saturate(max(sobelDepth, sobelNormal));

				float luminance = Luminance(screenColor);
				luminance = 1 - luminance;
				luminance = floor(luminance * _Posterization) / _Posterization;
				float crosshatches = UNITY_SAMPLE_TEX2DARRAY(_Crosshatches, float3(uv * 20, luminance * _Posterization));

				return lerp(crosshatches, _OutlineColor, outline);
			}
            
            ENDCG
        }
    }
}
