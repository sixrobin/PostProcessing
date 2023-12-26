namespace RSPostProcessing
{
    using UnityEngine;

    [ExecuteInEditMode]
    [AddComponentMenu("RSPostProcessing/Sharpen")]
    public class Sharpen : CameraPostEffect
    {
        private static readonly int SIZE_ID = Shader.PropertyToID("_Size");
        private static readonly int INTENSITY_ID = Shader.PropertyToID("_Intensity");
        
        [SerializeField, Range(0.00005f, 0.0008f)]
        private float size = 0.0001f;
        [SerializeField, Range(0.5f, 4f)]
        private float intensity = 2f;

        protected override string ShaderName => "RSPostProcessing/Sharpen";

        protected override void OnBeforeRenderImage(RenderTexture source, RenderTexture destination, Material material)
        {
            this.Material.SetFloat(SIZE_ID, this.size);
            this.Material.SetFloat(INTENSITY_ID, this.intensity);
        }
    }
}