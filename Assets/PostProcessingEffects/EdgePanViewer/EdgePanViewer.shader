Shader "RSPostProcessing/Edge Pan Viewer"
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
            float4 _EdgeMargins;
            fixed _FullSpeedThreshold;
            float _Alpha;

            fixed4 computeSideMask(float2 uv, fixed4 margins)
            {
                float screenRatio = _ScreenParams.x / _ScreenParams.y;

                fixed left = step(1 - margins.x / screenRatio, -uv.x);
                fixed right = step(1 - margins.y / screenRatio, uv.x);
                fixed up = step(1 - margins.z, uv.y);
                fixed down = step(1 - margins.w, -uv.y);

                return fixed4(left, right, up, down);
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
                fixed4 color = tex2D(_MainTex, i.uv);

                float2 uv = (i.uv - 0.5) * 2;
                float viewer_width = 0.005;

                // Compute each side mask.
                fixed4 maskSidesBase = computeSideMask(uv, _EdgeMargins);
                fixed4 maskSidesBase_in = computeSideMask(uv, _EdgeMargins - viewer_width);
                fixed4 maskSidesFullSpeedThreshold = computeSideMask(uv, _EdgeMargins * _FullSpeedThreshold);
                fixed4 maskSidesFullSpeedThreshold_in = computeSideMask(uv, _EdgeMargins * _FullSpeedThreshold - viewer_width);
                
                // Compute masks by adding sides.
                float2 maskBase = float2(maskSidesBase.x + maskSidesBase.y, maskSidesBase.z + maskSidesBase.w);
                float2 maskIn = float2(maskSidesBase_in.x + maskSidesBase_in.y, maskSidesBase_in.z + maskSidesBase_in.w);
                float2 maskFullSpeedThreshold = float2(maskSidesFullSpeedThreshold.x + maskSidesFullSpeedThreshold.y, maskSidesFullSpeedThreshold.z + maskSidesFullSpeedThreshold.w);
                float2 maskFullSpeedThresholdIn = float2(maskSidesFullSpeedThreshold_in.x + maskSidesFullSpeedThreshold_in.y, maskSidesFullSpeedThreshold_in.z + maskSidesFullSpeedThreshold_in.w);

                // Compute final mask.
                float2 mask = lerp(maskBase, maskBase - maskIn, 0.9);
                mask += maskFullSpeedThreshold - maskFullSpeedThresholdIn;
                mask += maskFullSpeedThreshold * 0.5;
                mask = saturate(mask);

                fixed4 edgeColor = fixed4(lerp(color.r, 1, mask.x), lerp(color.g, 1, mask.y), color.b, 1);
                return lerp(color, edgeColor, _Alpha);
            }
            
            ENDCG
        }
    }
}
