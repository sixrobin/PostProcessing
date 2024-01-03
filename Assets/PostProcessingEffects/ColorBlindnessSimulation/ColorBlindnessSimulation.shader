Shader "RSPostProcessing/Color Blindness Simulation"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader
    {
        CGINCLUDE
        
        #include "UnityCG.cginc"
        #include "ColorBlindnessData.cginc"

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

        v2f vert(appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = v.uv;
            return o;
        }

        sampler2D _MainTex;
        float _Severity;
        int _Difference;
        
        float luminance(float3 color)
        {
            return dot(color, float3(0.299, 0.587, 0.114));
        }

        void ComputeColorBlindness(float3 color, const float3x3 severities[11], out float3 color_blindness)
        {
            int s1 = min(10, floor(_Severity * 10));
            int s2 = min(10, floor((_Severity + 0.1) * 10));
            float weight = frac(_Severity * 10);

            float3x3 blindness = lerp(severities[s1], severities[s2], weight);
            color_blindness = mul(blindness, color.rgb);

            if (_Difference == 1)
            {
                float3 difference = abs(color.rgb - color_blindness);
                color_blindness = lerp(luminance(color), float3(1, 0, 0), saturate(dot(difference, 1)));
            }

            color_blindness = saturate(color_blindness);
        }
        
        ENDCG

        Pass
        {
            Name "Protanomaly" // L cone - Red.

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv);
                float3 color_blindness = float3(0, 0, 0);
                ComputeColorBlindness(color, protanomaly, color_blindness);
                return fixed4(color_blindness, 1);
            }
            
            ENDCG
        }

        Pass
        {
            Name "Deuteranomaly" // M cone - Green.

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv);
                float3 color_blindness = float3(0, 0, 0);
                ComputeColorBlindness(color, deuteranomaly, color_blindness);
                return fixed4(color_blindness, 1);
            }
            
            ENDCG
        }

        Pass
        {
            Name "Tritanomaly" // S cone - Blue.
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv);
                float3 color_blindness = float3(0, 0, 0);
                ComputeColorBlindness(color, tritanomaly, color_blindness);
                return fixed4(color_blindness, 1);
            }
            
            ENDCG
        }
        
        Pass
        {
            Name "Achromatopsia" // Total color blindness: no ability to see color.
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv);
                float3 color_blindness = lerp(color, luminance(color), _Severity);
                return fixed4(color_blindness, 1);
            }
            
            ENDCG
        }
    }
}
