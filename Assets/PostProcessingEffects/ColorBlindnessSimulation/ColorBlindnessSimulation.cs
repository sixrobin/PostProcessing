namespace RSPostProcessing
{
    using UnityEngine;

    [ExecuteInEditMode]
    [AddComponentMenu("RSPostProcessing/Color Blindness Simulation")]
    public class ColorBlindnessSimulation : CameraPostEffect
    {
        private static readonly int SEVERITY_ID = Shader.PropertyToID("_Severity");
        private static readonly int DIFFERENCE_ID = Shader.PropertyToID("_Difference");
        
        private enum ColorBlindnessType
        {
            [InspectorName("Protanomaly (L cone - Red)")]      PROTANOMALY,
            [InspectorName("Deuteranomaly (M cone - Green)")]  DEUTERANOMALY,
            [InspectorName("Tritanomaly (S cone - Blue)")]     TRITANOMALY,
            [InspectorName("Achromatopsia (Total blindness)")] ACHROMATOPSIA
        }

        [SerializeField]
        private ColorBlindnessType _colorBlindnessType = ColorBlindnessType.PROTANOMALY;

        [SerializeField, Range(0f, 1f)]
        private float _severity = 1f;

        [SerializeField]
        private bool _difference = false;

        protected override string ShaderName => "RSPostProcessing/Color Blindness Simulation";

        protected override int Pass => (int)_colorBlindnessType;

        protected override void OnBeforeRenderImage(RenderTexture source, RenderTexture destination, Material material)
        {
            Material.SetFloat(SEVERITY_ID, _severity);
            Material.SetInt(DIFFERENCE_ID, _difference ? 1 : 0);
        }
    }
}