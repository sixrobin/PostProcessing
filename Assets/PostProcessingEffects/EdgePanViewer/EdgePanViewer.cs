namespace RSPostProcessing
{
    using UnityEngine;

    [ExecuteInEditMode]
    [AddComponentMenu("RSPostProcessing/Edge Pan Viewer")]
    public class EdgePanViewer : CameraPostEffect
    {
        private static readonly int EDGE_MARGIN_SHADER_ID = Shader.PropertyToID("_EdgeMargins");
        private static readonly int FULL_SPEED_THRESHOLD_ID = Shader.PropertyToID("_FullSpeedThreshold");
        private static readonly int ALPHA_SHADER_ID = Shader.PropertyToID("_Alpha");

        [Header("SETTINGS")]
        [SerializeField]
        private Vector4 margin;
        [SerializeField, Range(0f, 1f)]
        private float fullSpeedThreshold;
        [SerializeField, Range(0f, 1f)]
        private float alpha = 1f;

        protected override string ShaderName => "RSPostProcessing/Edge Pan Viewer";

        protected override void OnBeforeRenderImage(RenderTexture source, RenderTexture destination, Material material)
        {
            this.Material.SetVector(EDGE_MARGIN_SHADER_ID, this.margin);
            this.Material.SetFloat(FULL_SPEED_THRESHOLD_ID, this.fullSpeedThreshold);
            this.Material.SetFloat(ALPHA_SHADER_ID, this.alpha);
        }
    }
}