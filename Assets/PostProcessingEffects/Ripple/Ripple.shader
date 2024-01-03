Shader "RSPostProcessing/Ripple"
{
    Properties
    {
        _MainTex ("Base", 2D) = "white" {}
        _GradTex ("Gradient", 2D) = "white" {}
        _Reflection ("Reflection Color", Color) = (0, 0, 0, 0)
        _Params1 ("Parameters 1", Vector) = (1, 1, 0.8, 0)
        _Params2 ("Parameters 2", Vector) = (1, 1, 1, 0)
        _Drop1 ("Drop 1", Vector) = (0.48, 0.5, 0, 0)
        _Drop2 ("Drop 2", Vector) = (0.59, 0.5, 0, 0)
        _Drop3 ("Drop 3", Vector) = (0.50, 0.5, 0, 0)
        _Drop4 ("Drop 4", Vector) = (0.51, 0.5, 0, 0)
        _Drop5 ("Drop 5", Vector) = (0.52, 0.5, 0, 0)
    }

    SubShader
    {
        Pass
        {
            ZTest Always
            Cull Off
            ZWrite Off
            
            Fog
            {
                Mode off
            }

            CGPROGRAM

            #pragma fragmentoption ARB_precision_hint_fastest 
            #pragma target 3.0
            #pragma vertex vert_img
            #pragma fragment frag

            ENDCG
        }
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    sampler2D _MainTex;
    float2 _MainTex_TexelSize;

    sampler2D _GradTex;

    half4 _Reflection;
    float4 _Params1;
    float4 _Params2;

    float3 _Drop1;
    float3 _Drop2;
    float3 _Drop3;
    float3 _Drop4;
    float3 _Drop5;

    float Wave(float2 position, float2 origin, float time)
    {
        float d = length(position - origin);
        float t = time - d * _Params1.z;
        return (tex2D(_GradTex, float2(t, 0)).a - 0.5f) * 2;
    }

    float WaveAll(float2 position)
    {
        return Wave(position, _Drop1.xy, _Drop1.z)
             + Wave(position, _Drop2.xy, _Drop2.z)
             + Wave(position, _Drop3.xy, _Drop3.z)
             + Wave(position, _Drop4.xy, _Drop4.z)
             + Wave(position, _Drop5.xy, _Drop5.z);
    }

    half4 frag(v2f_img i) : SV_Target
    {
        const float2 dx = float2(0.01f, 0);
        const float2 dy = float2(0, 0.01f);

        float2 p = i.uv * _Params1.xy;

        float w = WaveAll(p);
        float2 dw = float2 (WaveAll(p + dx) - w, WaveAll(p + dy) - w);

        float2 duv = dw * _Params2.xy * 0.2f * _Params2.z;
        half4 c = tex2D(_MainTex, i.uv + duv);
        float fr = pow(length(dw) * 3 * _Params2.w, 3);

        return lerp(c, _Reflection, fr);
    }

    ENDCG
}
