Shader "RSPostProcessing/Fast Gaussian Blur"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    sampler2D _MainTex;
    float4 _MainTex_TexelSize;

    // 9-tap Gaussian filter with linear sampling.
    // http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/
    half4 gaussianFilter(float2 uv, float2 stride)
    {
        half4 s = tex2D(_MainTex, uv) * 0.227027027;

        float2 d1 = stride * 1.3846153846;
        s += tex2D(_MainTex, uv + d1) * 0.3162162162;
        s += tex2D(_MainTex, uv - d1) * 0.3162162162;

        float2 d2 = stride * 3.2307692308;
        s += tex2D(_MainTex, uv + d2) * 0.0702702703;
        s += tex2D(_MainTex, uv - d2) * 0.0702702703;

        return s;
    }

    half4 fragQuarter(v2f_img i) : SV_Target
    {
        float4 d = _MainTex_TexelSize.xyxy * float4(1, 1, -1, -1);
        half4 s = tex2D(_MainTex, i.uv + d.xy);
        s += tex2D(_MainTex, i.uv + d.xw);
        s += tex2D(_MainTex, i.uv + d.zy);
        s += tex2D(_MainTex, i.uv + d.zw);
        return s * 0.25;
    }

    half4 fragBlurHorizontal(v2f_img i) : SV_Target
    {
        return gaussianFilter(i.uv, float2(_MainTex_TexelSize.x, 0));
    }

    half4 fragBlurVertical(v2f_img i) : SV_Target
    {
        return gaussianFilter(i.uv, float2(0, _MainTex_TexelSize.y));
    }

    ENDCG

    Subshader
    {
        Pass
        {
            ZTest Always
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            
            #pragma vertex vert_img
            #pragma fragment fragQuarter
            
            ENDCG
        }

        Pass
        {
            ZTest Always
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            
            #pragma vertex vert_img
            #pragma fragment fragBlurHorizontal
            #pragma target 3.0
            
            ENDCG
        }

        Pass
        {
            ZTest Always
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            
            #pragma vertex vert_img
            #pragma fragment fragBlurVertical
            #pragma target 3.0
            
            ENDCG
        }
    }
}