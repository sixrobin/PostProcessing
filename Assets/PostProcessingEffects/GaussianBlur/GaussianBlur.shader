Shader "RSPostProcessing/Gaussian Blur"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
    }
    
    SubShader
    {
        ZTest Always
        Cull Off
        ZWrite Off
        
        Fog
        {
            Mode Off
        }
 
        Pass
        {
            CGPROGRAM
     
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
     
            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float stepW;
            float stepH;
     
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv  : TEXCOORD0;
            };
         
            float4 _MainTex_ST;
            float4 _MainTex_ST_TexelSize;
     
            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : COLOR
            {
                stepW = _MainTex_TexelSize.x;
                stepH = _MainTex_TexelSize.y;
         
                const float2 offset[25] =
                {
                    float2(-stepW * 2, -stepH * 2), float2(-stepW, -stepH * 2), float2(0, -stepH * 2), float2(stepW, -stepH * 2), float2(stepW * 2, -stepH * 2),
                    float2(-stepW * 2, -stepH),     float2(-stepW, -stepH),     float2(0, -stepH),     float2(stepW, -stepH),     float2(stepW * 2, -stepH),
                    float2(-stepW * 2, 0),          float2(-stepW, 0),          float2(0, 0),          float2(stepW, 0),          float2(stepW * 2, 0),
                    float2(-stepW * 2, stepH),      float2(-stepW, stepH),      float2(0, stepH),      float2(stepW, stepH),      float2(stepW * 2, stepH),
                    float2(-stepW * 2, stepH * 2),  float2(-stepW, stepH * 2),  float2(0, stepH * 2),  float2(stepW, stepH * 2),  float2(stepW * 2, stepH * 2),
                };
         
                const float kernel[25] =
                {
                    0.003765, 0.015019, 0.023792, 0.015019, 0.003765,
                    0.015019, 0.059912, 0.094907, 0.059912, 0.015019,
                    0.023792, 0.094907, 0.150342, 0.094907, 0.023792,
                    0.015019, 0.059912, 0.094907, 0.059912, 0.015019,
                    0.003765, 0.015019, 0.023792, 0.015019, 0.003765,
                };
         
                float4 sum = float4(0, 0, 0, 0);

                [unroll]
                for (int j = 0; j < 25; j++)
                    sum += tex2D(_MainTex, i.uv + offset[j]) * kernel[j];

                return sum;
            }
           
            ENDCG
        }
    }
}