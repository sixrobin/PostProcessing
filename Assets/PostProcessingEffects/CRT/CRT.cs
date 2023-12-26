namespace RSPostProcessing
{
    using UnityEngine;
    
    [ExecuteInEditMode]
    [DisallowMultipleComponent]
    [AddComponentMenu("RSPostProcessing/CRT")]
    public class CRT : CameraPostEffect
    {
        private static readonly int CURVATURE_ID = Shader.PropertyToID("_Curvature");
        private static readonly int VIGNETTE_WIDTH_ID = Shader.PropertyToID("_VignetteWidth");
        private static readonly int SCANLINES_MULTIPLIER_ID = Shader.PropertyToID("_ScanlinesMultiplier");
        private static readonly int RGB_MULTIPLIER_ID = Shader.PropertyToID("_RGBMultiplier");
        
        [SerializeField, Range(1f, 30f)]
        private float _curvature = 8f;
        [SerializeField, Range(0f, 100f)]
        private float _vignetteWidth = 50f;
        [SerializeField, Range(0.5f, 3f)]
        private float _scanlinesMultiplier = 1f;
        [SerializeField]
        private Vector3 _rgbMultiplier = new(0.25f, 0.2f, 0.3f);
        
        protected override string ShaderName => "RSPostProcessing/CRT";

        protected override void OnBeforeRenderImage(RenderTexture source, RenderTexture destination, Material material)
        {
            material.SetFloat(CURVATURE_ID, _curvature);
            material.SetFloat(VIGNETTE_WIDTH_ID, _vignetteWidth);
            material.SetFloat(SCANLINES_MULTIPLIER_ID, _scanlinesMultiplier);
            material.SetVector(RGB_MULTIPLIER_ID, _rgbMultiplier);
        }
    }
}