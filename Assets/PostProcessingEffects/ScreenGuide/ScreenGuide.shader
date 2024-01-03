Shader "RSPostProcessing/Screen Guide"
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
            #pragma multi_compile _ ALWAYSSHOWCENTER

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
            fixed _LinesX;
            fixed _LinesY;
            fixed _LineScale;
            fixed4 _ColorX;
            fixed4 _ColorY;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed screen_ratio = _ScreenParams.x / _ScreenParams.y;

                // Compute guideline width.
                fixed guide_width = 0.001 * 1920 / _ScreenParams.y;
                guide_width *= max(1, _LineScale);

                // Compute space between guidelines.
                fixed2 spacing = fixed2(1 / (_LinesX + 1), 1 / (_LinesY + 1));

                fixed2 mask = 0;

                // Compute vertical lines.
                for (int x = 0; x < _LinesX; ++x)
                {
                    fixed guide_position = spacing.x * (x + 1);
                    mask.x += step(i.uv.x - (guide_width / screen_ratio) * 0.5, guide_position) - step(i.uv.x + (guide_width / screen_ratio) * 0.5, guide_position);
                }

                // Compute horizontal lines.
                for (int y = 0; y < _LinesY; ++y)
                {
                    fixed guide_position = spacing.y * (y + 1);
                    mask.y += step(i.uv.y - guide_width * 0.5, guide_position) - step(i.uv.y + guide_width * 0.5, guide_position);
                }

                #if defined (ALWAYSSHOWCENTER)
                mask.x += step(i.uv.x - (guide_width / screen_ratio) * 0.5, 0.5) - step(i.uv.x + (guide_width / screen_ratio) * 0.5, 0.5);
                mask.y += step(i.uv.y - guide_width * 0.5, 0.5) - step(i.uv.y + guide_width * 0.5, 0.5);
                #endif

                mask = saturate(mask);

                // Final color computation.
                fixed4 color_base = tex2D(_MainTex, i.uv);
                fixed4 color_guide = lerp(color_base, _ColorX * mask.x, _ColorX.a) + lerp(color_base, _ColorY * mask.y, _ColorY.a);
                fixed4 color = lerp(color_base, color_guide, max(mask.x, mask.y));

                return color;
            }
            
            ENDCG
        }
    }
}
