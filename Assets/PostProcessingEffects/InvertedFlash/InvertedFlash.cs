namespace RSPostProcessing
{
    using UnityEngine;

    [ExecuteInEditMode]
    [AddComponentMenu("RSPostProcessing/Inverted Flash")]
    public class InvertedFlash : CameraPostEffect
    {
        private static readonly int PERCENTAGE_ID = Shader.PropertyToID("_Percentage");
        private static readonly int DESATURATE_ID = Shader.PropertyToID("_Desaturate");
        private static readonly int DESATURATION_SMOOTHSTEP_ID = Shader.PropertyToID("_DesaturationSmoothstep");
        
        [SerializeField, Range(0f, 1f)]
        private float _percentage = 1f;

        [SerializeField]
        public bool Desaturated = true;

        [SerializeField]
        private Vector2 _desaturationSmoothstep = new Vector2(0.45f, 0.55f);

        protected override string ShaderName => "RSPostProcessing/Inverted Flash";
        
        public float Percentage
        {
            get => _percentage;
            set => _percentage = Mathf.Clamp01(value);
        }

        protected override void OnBeforeRenderImage(RenderTexture source, RenderTexture destination, Material material)
        {
            material.SetFloat(PERCENTAGE_ID, _percentage);
            material.SetFloat(DESATURATE_ID, Desaturated ? 1f : 0f);
            material.SetVector(DESATURATION_SMOOTHSTEP_ID, _desaturationSmoothstep);
        }

        private void OnValidate()
        {
            _desaturationSmoothstep.x = Mathf.Clamp01(_desaturationSmoothstep.x);
            _desaturationSmoothstep.y = Mathf.Clamp01(_desaturationSmoothstep.y);
        }
    }
}