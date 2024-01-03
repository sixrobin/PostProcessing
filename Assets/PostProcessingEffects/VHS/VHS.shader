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

            float3 hash23(float2 input)
            {
                float a = dot(input.xyx, float3(127.1, 311.7, 74.7));
                float b = dot(input.yxx, float3(269.5, 183.3, 246.1));
                float c = dot(input.xyy, float3(113.5, 271.9, 124.6));
                return frac(sin(float3(a, b, c)) * 43758.5453123);
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

                float offsetDistance = 5; // TODO: Expose this.
                float pixelWidth = 1.0 / _ScreenParams.x;

                // Chromatic aberration.
                float sampleOffset = interlacingMask * offsetDistance * pixelWidth;
                float3 leftSampleTone = float3(0, 1, 1);
                float3 leftSample = tex2D(_MainTex, float2(i.uv.x + sampleOffset, i.uv.y)).rgb * leftSampleTone;
                float3 rightSample = tex2D(_MainTex, float2(i.uv.x - sampleOffset, i.uv.y)).rgb * (1 - leftSampleTone);
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
