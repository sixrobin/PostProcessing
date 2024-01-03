namespace RSPostProcessing
{
    using UnityEngine;

    [ExecuteInEditMode]
    [AddComponentMenu("RSPostProcessing/VHS")]
    public class VHS : CameraPostEffect
    {
        private static readonly int CHROMATIC_ABERRATION_LEFT_TONE_ID = Shader.PropertyToID("_ChromaticAberrationLeftTone");
        private static readonly int CHROMATIC_ABERRATION_PIXEL_SIZE_ID = Shader.PropertyToID("_ChromaticAberrationPixelSize");
        private static readonly int TRACKING_LINE_SMOOTHSTEP_MIN_ID = Shader.PropertyToID("_TrackingLineSmoothstepMin");
        private static readonly int TRACKING_LINE_SMOOTHSTEP_MAX_ID = Shader.PropertyToID("_TrackingLineSmoothstepMax");
        private static readonly int TRACKING_LINE_OFFSET_MULTIPLIER_ID = Shader.PropertyToID("_TrackingLineOffsetMultiplier");
        private static readonly int TRACKING_LINE_TIME_OFFSET_MULTIPLIER_ID = Shader.PropertyToID("_TrackingLineTimeOffsetMultiplier");
        private static readonly int TRACKING_LINE_COLOR_SHIFT_MULTIPLIER_ID = Shader.PropertyToID("_TrackingLineColorShiftMultiplier");
        private static readonly int WHITE_NOISE_MASK_POWER_ID = Shader.PropertyToID("_WhiteNoiseMaskPower");

        [Header("SETTINGS")]
        [SerializeField]
        private Color _chromaticAberrationLeftTone = Color.cyan;
        [SerializeField, Min(0)]
        private int _chromaticAberrationPixelSize = 5;
        [SerializeField, Range(0f, 1f)]
        private float _trackingLineSmoothstepMin = 0.9f;
        [SerializeField, Range(0f, 1f)]
        private float _trackingLineSmoothstepMax = 0.95f;
        [SerializeField, Range(0f, 1f)]
        private float _trackingLineOffsetMultiplier = 0.03f;
        [SerializeField, Range(0f, 1f)]
        private float _trackingLineTimeOffsetMultiplier = 0.2f;
        [SerializeField, Range(0f, 1f)]
        private float _trackingLineColorShiftMultiplier = 0.3f;
        [SerializeField, Min(1)]
        private float _whiteNoiseMaskPower = 50f;
        
        protected override string ShaderName => "RSPostProcessing/VHS";

        protected override void OnBeforeRenderImage(RenderTexture source, RenderTexture destination, Material material)
        {
            material.SetColor(CHROMATIC_ABERRATION_LEFT_TONE_ID, _chromaticAberrationLeftTone);
            material.SetFloat(CHROMATIC_ABERRATION_PIXEL_SIZE_ID, _chromaticAberrationPixelSize);
            material.SetFloat(TRACKING_LINE_SMOOTHSTEP_MIN_ID, _trackingLineSmoothstepMin);
            material.SetFloat(TRACKING_LINE_SMOOTHSTEP_MAX_ID, _trackingLineSmoothstepMax);
            material.SetFloat(TRACKING_LINE_OFFSET_MULTIPLIER_ID, _trackingLineOffsetMultiplier);
            material.SetFloat(TRACKING_LINE_TIME_OFFSET_MULTIPLIER_ID, _trackingLineTimeOffsetMultiplier);
            material.SetFloat(TRACKING_LINE_COLOR_SHIFT_MULTIPLIER_ID, _trackingLineColorShiftMultiplier);
            material.SetFloat(WHITE_NOISE_MASK_POWER_ID, _whiteNoiseMaskPower);
        }
    }
}