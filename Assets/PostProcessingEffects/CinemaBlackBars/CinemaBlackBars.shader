Shader "RSPostProcessing/Cinema Black Bars"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Width ("Width", Range(0, 1)) = 0.25
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
            fixed _Width;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 uv_bars = abs((i.uv - 0.5) * 2);
                float bars = step(uv_bars.y, 1 - _Width);
                return tex2D(_MainTex, i.uv) * bars;
            }
            
            ENDCG
        }
    }
}