namespace RSPostProcessing
{
    using UnityEngine;

    [ExecuteInEditMode]
    [AddComponentMenu("RSPostProcessing/Dithering")]
    public class Dithering : CameraPostEffect
    {
        private static readonly int POSTERIZATION_STEPS_ID = Shader.PropertyToID("_PosterizationSteps");
        private static readonly int DITHER_SCALE_ID = Shader.PropertyToID("_DitherScale");
        private static readonly int COLOR_RAMP_ID = Shader.PropertyToID("_ColorRamp");
        private static readonly int RAMP_INTENSITY_ID = Shader.PropertyToID("_RampIntensity");
        private static readonly int INVERT_RAMP_ID = Shader.PropertyToID("_InvertRamp");

        [SerializeField, Min(2)]
        private int _posterizationSteps = 8;
        [SerializeField, Range(0f, 1f)]
        private float _ditherScale = 1f;

        [SerializeField]
        private Texture2D _colorRamp;
        [SerializeField, Range(0f, 1f)]
        private float _rampIntensity;
        [SerializeField]
        private bool _invertRamp;
        
        protected override string ShaderName => "RSPostProcessing/Dithering";
        
        protected override void OnBeforeRenderImage(RenderTexture source, RenderTexture destination, Material material)
        {
            material.SetInt(POSTERIZATION_STEPS_ID, this._posterizationSteps);
            material.SetFloat(DITHER_SCALE_ID, this._ditherScale);
            material.SetTexture(COLOR_RAMP_ID, this._colorRamp);
            material.SetFloat(RAMP_INTENSITY_ID, this._rampIntensity);
            material.SetFloat(INVERT_RAMP_ID, this._invertRamp ? 1f : 0f);
        }
    }
}