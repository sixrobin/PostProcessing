Shader "RSPostProcessing/Sobel Outline"
{
    Properties
    {
    	_MainTex ("Main Tex", 2D) = "white" {}
	    _OutlineThickness ("Outline Thickness", Float) = 1
	    _OutlineStep ("Outline Step", Range(0, 1)) = 0.01
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
			float _OutlineThickness;
			float _OutlineStep;
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
            
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
            
			float4 frag(v2f i) : SV_Target
			{
				float2 offset = float2(1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y) * _OutlineThickness;
				float outline = step(_OutlineStep, sobel(i.uv, offset));
				float4 color = tex2D(_MainTex, i.uv);
				return lerp(color, _OutlineColor, outline);
			}
            
            ENDCG
        }
    }
}
