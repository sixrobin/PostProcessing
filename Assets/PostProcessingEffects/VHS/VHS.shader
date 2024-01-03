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

            float2 Rotate(float2 uv, float rotation)
            {
                float s = sin(rotation);
                float c = cos(rotation);
                
                float2x2 rotationMatrix = float2x2(c, -s, s, c);
                rotationMatrix *= 0.5;
                rotationMatrix += 0.5;
                rotationMatrix = rotationMatrix * 2 - 1;
                
                uv.xy = mul(uv.xy, rotationMatrix);
                
                return uv;
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

                // Noisy tape mask.
                float3 noisyTapeRandomColor = hash23(float2(i.uv.y, _Time.y));
                float noisyTapeMask = noisyTapeRandomColor.r / (_ScreenParams.x * 0.25);
                float2 noisyTapeUV = i.uv + noisyTapeMask;

                // Tracking line mask.
                float scanlinesMask = smoothstep(0.3, 0.7, noisyTapeRandomColor.y);
                float trackingLineTimeOffset = hash23(float2(0.67, 0.57) * _Time.y).x * 0.15; // TODO: Expose 0.15 value.
                float trackingLineMask = sin(noisyTapeUV.y * 8 - (_Time.y + trackingLineTimeOffset) * 2);
                trackingLineMask = smoothstep(0.9, 0.96, trackingLineMask); // TODO: Expose values.
                float trackingLineOffset = (trackingLineMask * scanlinesMask) * 0.03; // TODO: Expose value.

                float offsetDistance = 5; // TODO: Expose value.
                float pixelWidth = 1.0 / _ScreenParams.x;

                // Chromatic aberration.
                float sampleOffset = interlacingMask * offsetDistance * pixelWidth;
                float2 colorSamplesUV = float2(i.uv.x - trackingLineOffset, i.uv.y); 
                float3 leftSampleTone = float3(0, 1, 1);
                float3 leftSample = tex2D(_MainTex, float2(colorSamplesUV.x + sampleOffset, colorSamplesUV.y)).rgb * leftSampleTone;
                float3 rightSample = tex2D(_MainTex, float2(colorSamplesUV.x - sampleOffset, colorSamplesUV.y)).rgb * (1 - leftSampleTone);
                float3 result = leftSample + rightSample;

                // White noise.
                float3 noiseColor = float3(2, 2, 2);
                float2 steppedScreenUV = floor(colorSamplesUV * (_ScreenParams.xy / 8)) / (_ScreenParams.xy / 8);
                float2 whiteNoiseMask = float2(hash23(float2(noisyTapeUV.y, _Time.y)).r, 0);
                whiteNoiseMask += steppedScreenUV;
                whiteNoiseMask.x *= 0.1;
                float3 noisedResult = lerp(result, noiseColor, pow(hash23(whiteNoiseMask).x, 30)); // TODO: Expose value.

                float noisedColorMask = (trackingLineMask * 0.7 + 0.3) * scanlinesMask;
                
                float3 yiqSpaceResult = RGBtoYIQ(noisedColorMask < 0.3 ? result : noisedResult);
                yiqSpaceResult *= float3(0.9, 1.1, 1.5);
                yiqSpaceResult += float3(0.1, -0.1, 0);
                yiqSpaceResult.yz = Rotate(yiqSpaceResult.yz, trackingLineMask * 0.3); // TODO: Expose value.
                result = YIQtoRGB(yiqSpaceResult);

                return fixed4(result, 1);
            }
            
            ENDCG
        }
    }
}
