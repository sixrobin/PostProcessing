Shader "RSPostProcessing/VHS"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" {}
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
                float2 uv     : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float3 RGBtoYIQ(float3 color)
            {
                const float3x3 rgb_to_yiq = { +0.2990, +0.5870, +0.1140,
                                              +0.5957, -0.2745, -0.3213,
                                              +0.2115, -0.5226, +0.3112 };
                return mul(color, rgb_to_yiq);
            }
            
            float3 YIQtoRGB(float3 color)
            {
                const float3x3 yiq_to_rgb = { +1.0000, +0.9563, +0.6210,
                                              +1.0000, -0.2721, -0.6474,
                                              +1.0000, -1.1070, +1.7046 };
                return mul(color, yiq_to_rgb);
            }
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Screen interlacing mask.
                float interlacingMask = floor((i.uv.y + _Time.y) * _ScreenParams.y) % 2;

                float pixelOffsetDistance = 5;
                float pixelWidth = 1.0 / _ScreenParams.x;

                // Chromatic aberration.
                float sampleOffset = interlacingMask * pixelOffsetDistance * pixelWidth;
                float3 rightSampleTone = float3(0, 1, 1);
                float2 leftSampleUV = float2(i.uv.x + sampleOffset, i.uv.y);
                float2 rightSampleUV = float2(i.uv.x - sampleOffset, i.uv.y);
                float3 leftSample = tex2D(_MainTex, leftSampleUV).rgb * rightSampleTone;
                float3 rightSample = tex2D(_MainTex, rightSampleUV).rgb * (1 - rightSampleTone);
                float3 result = leftSample + rightSample;

                float3 yiqSpaceResult = RGBtoYIQ(result);
                yiqSpaceResult *= float3(0.9, 1.1, 1.5);
                yiqSpaceResult += float3(0.1, -0.1, 0);
                result = YIQtoRGB(yiqSpaceResult);

                return fixed4(result, 1);
            }
            
            ENDCG
        }
    }
}
