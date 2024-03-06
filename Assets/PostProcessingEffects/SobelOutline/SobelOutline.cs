namespace RSPostProcessing
{
    using UnityEngine;

    [ExecuteInEditMode]
    [AddComponentMenu("RSPostProcessing/Sobel Outline")]
    public class SobelOutline : CameraPostEffect
    {
        private static readonly int OUTLINE_THICKNESS_ID = Shader.PropertyToID("_OutlineThickness");
        private static readonly int OUTLINE_STEP_ID = Shader.PropertyToID("_OutlineStep");
        private static readonly int OUTLINE_COLOR_ID = Shader.PropertyToID("_OutlineColor");

        [SerializeField, Min(1)]
        private int _outlineThickness = 3;
        [SerializeField, Range(0f, 0.1f)]
        private float _outlineStep = 0.05f;
        [SerializeField]
        private Color _outlineColor = Color.black;

        protected override string ShaderName => "RSPostProcessing/Sobel Outline";
        
        protected override void OnBeforeRenderImage(RenderTexture source, RenderTexture destination, Material material)
        {
            material.SetFloat(OUTLINE_THICKNESS_ID, this._outlineThickness);
            material.SetFloat(OUTLINE_STEP_ID, this._outlineStep);
            material.SetColor(OUTLINE_COLOR_ID, this._outlineColor);
        }
    }
}