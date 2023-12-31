Shader "RSPostProcessing/VHS"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" {}
        
        _ChromaticAberrationLeftTone ("Chromatic Aberration Left Tone", Color) = (0, 1, 1, 1)
        _ChromaticAberrationPixelSize ("Chromatic Aberration Pixel Size", Float) = 5
        _TrackingLineSmoothstepMin ("Tracking Line Smoothstep Min", Range(0, 1)) = 0.9
        _TrackingLineSmoothstepMax ("Tracking Line Smoothstep Max", Range(0, 1)) = 0.95
        _TrackingLineOffsetMultiplier ("Tracking Line Offset Multiplier", Range(0, 1)) = 0.03
        _TrackingLineTimeOffsetMultiplier ("Tracking Line Time Offset Multiplier", Range(0, 1)) = 0.2
        _TrackingLineColorShiftMultiplier ("Tracking Line Color Shift Multiplier", Range(0, 1)) = 0.3
        _WhiteNoiseMaskPower ("White Noise Mask Power", Float) = 30
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
                float4 vertex : SV_POSITION;
                float2 uv     : TEXCOORD0;
            };

            sampler2D _MainTex;
            float3 _ChromaticAberrationLeftTone;
            float _ChromaticAberrationPixelSize;
            float _TrackingLineSmoothstepMin;
            float _TrackingLineSmoothstepMax;
            float _TrackingLineOffsetMultiplier;
            float _TrackingLineTimeOffsetMultiplier;
            float _TrackingLineColorShiftMultiplier;
            float _WhiteNoiseMaskPower;

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

            float hash(float2 input)
            {
                return frac(sin(dot(input.xyx, float3(127.1, 311.7, 74.7))) * 43758.5453123);
            }
            float2 hash22(float2 input)
            {
                float a = dot(input.xyx, float3(127.1, 311.7, 74.7));
                float b = dot(input.yxx, float3(269.5, 183.3, 246.1));
                return frac(sin(float2(a, b)) * 43758.5453123);
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
                float trackingLineTimeOffset = hash(float2(0.67, 0.57) * _Time.y) * _TrackingLineTimeOffsetMultiplier;
                float trackingLineMask = sin(noisyTapeUV.y * 8 - (_Time.y + trackingLineTimeOffset) * 2);
                trackingLineMask = smoothstep(_TrackingLineSmoothstepMin, _TrackingLineSmoothstepMax, trackingLineMask);
                trackingLineMask *= scanlinesMask;
                float trackingLineOffset = trackingLineMask * _TrackingLineOffsetMultiplier;
                
                // Chromatic aberration.
                float pixelWidth = 1.0 / _ScreenParams.x;
                float sampleOffset = interlacingMask * (_ChromaticAberrationPixelSize * pixelWidth);
                float2 colorSamplesUV = float2(i.uv.x - trackingLineOffset, i.uv.y); 
                float3 leftSample = tex2D(_MainTex, float2(colorSamplesUV.x + sampleOffset, colorSamplesUV.y)).rgb * _ChromaticAberrationLeftTone;
                float3 rightSample = tex2D(_MainTex, float2(colorSamplesUV.x - sampleOffset, colorSamplesUV.y)).rgb * (1 - _ChromaticAberrationLeftTone);
                float3 result = leftSample + rightSample;

                // White noise.
                float3 noiseColor = float3(2, 2, 2);
                float2 steppedScreenUV = floor(colorSamplesUV * (_ScreenParams.xy / 8)) / (_ScreenParams.xy / 8);
                float2 whiteNoiseMask = float2(hash(float2(noisyTapeUV.y, _Time.y)), 0);
                whiteNoiseMask += steppedScreenUV;
                whiteNoiseMask.x *= 0.1;
                float3 noisedResult = lerp(result, noiseColor, pow(hash(whiteNoiseMask), _WhiteNoiseMaskPower));

                float noisedColorMask = (trackingLineMask * 0.7 + 0.3) * scanlinesMask;
                
                float3 yiqSpaceResult = RGBtoYIQ(noisedColorMask < 0.3 ? result : noisedResult);
                yiqSpaceResult *= float3(0.9, 1.1, 1.5);
                yiqSpaceResult += float3(0.1, -0.1, 0);
                yiqSpaceResult.yz = Rotate(yiqSpaceResult.yz, trackingLineMask * _TrackingLineColorShiftMultiplier);
                result = YIQtoRGB(yiqSpaceResult);

                return fixed4(result, 1);
            }
            
            ENDCG
        }
    }
}
