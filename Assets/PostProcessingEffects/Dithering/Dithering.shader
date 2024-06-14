Shader "RSPostProcessing/Dithering"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
     
        _PosterizationSteps ("Posterization Steps", int) = 8
        _DitherScale ("Dither Scale", Range(0, 1)) = 1
        
        _ColorRamp ("Color Ramp", 2D) = "white" {}
        _RampIntensity ("Ramp Intensity", Range(0, 1)) = 1
        [Toggle] _InvertRamp ("Invert Ramp", Float) = 0
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
            int _PosterizationSteps;
            float _DitherScale;
            
            sampler2D _ColorRamp;
            float _InvertRamp;
            float _RampIntensity;

            float4 dither(float4 color, float2 screenPos)
            {
                float2 screenUV = screenPos * _ScreenParams.xy;
                
                const float thresholds[16] =
                {
                    1.0 / 17.0,   9.0 / 17.0,   3.0 / 17.0,   11.0 / 17.0,
                    13.0 / 17.0,  5.0 / 17.0,   15.0 / 17.0,  7.0 / 17.0,
                    4.0 / 17.0,   12.0 / 17.0,  2.0 / 17.0,   10.0 / 17.0,
                    16.0 / 17.0,  8.0 / 17.0,   14.0 / 17.0,  6.0 / 17.0
                };
                
                uint index = (uint(screenUV.x) % 4) * 4 + uint(screenUV.y) % 4;
                return color - thresholds[index];
            }

            float4 posterize(float4 color, float4 steps)
            {
                return floor(color / (1 / steps)) * (1 / steps);
            }
            
            v2f vert(const appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(const v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv);

                float4 rampColor = tex2D(_ColorRamp, _InvertRamp ? 1 - Luminance(color) : Luminance(color));
                color = lerp(color, rampColor, _RampIntensity);
                
                fixed4 posterized = posterize(color, _PosterizationSteps);
                float4 dithered = dither(posterized, i.uv * _DitherScale);

                return dithered + 0.1;
            }
            
            ENDCG
        }
    }
}