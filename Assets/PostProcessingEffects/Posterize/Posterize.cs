namespace RSPostProcessing
{
    using UnityEngine;

    [ExecuteInEditMode]
    [AddComponentMenu("RSPostProcessing/Posterize")]
    public class Posterize : CameraPostEffect
    {
        private static readonly int STEPS_ID = Shader.PropertyToID("_Steps");

        [SerializeField, Range(1, 255)]
        public int _steps = 4;

        protected override string ShaderName => "RSPostProcessing/Posterize";

        public int Steps
        {
            get => _steps;
            set => _steps = Mathf.Clamp(value, 1, 255);
        }

        protected override void OnBeforeRenderImage(RenderTexture source, RenderTexture destination, Material material)
        {
            material.SetFloat(STEPS_ID, _steps);
        }
    }
}