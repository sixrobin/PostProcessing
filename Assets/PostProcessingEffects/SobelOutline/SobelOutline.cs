namespace RSPostProcessing
{
    using UnityEngine;

    [ExecuteInEditMode]
    [AddComponentMenu("RSPostProcessing/Sobel Outline")]
    public class SobelOutline : CameraPostEffect
    {
        private static readonly int OUTLINE_THICKNESS_ID = Shader.PropertyToID("_OutlineThickness");
        private static readonly int OUTLINE_DEPTH_MULTIPLIER_ID = Shader.PropertyToID("_OutlineDepthMultiplier");
        private static readonly int OUTLINE_DEPTH_BIAS_ID = Shader.PropertyToID("_OutlineDepthBias");
        private static readonly int OUTLINE_COLOR_ID = Shader.PropertyToID("_OutlineColor");

        [SerializeField, Min(1)]
        private int _outlineThickness = 3;
        [SerializeField]
        private float _outlineDepthMultiplier = 1f;
        [SerializeField]
        private float _outlineDepthBias = 1f;
        [SerializeField]
        private Color _outlineColor = Color.black;

        protected override string ShaderName => "RSPostProcessing/Sobel Outline";
        
        protected override void OnBeforeRenderImage(RenderTexture source, RenderTexture destination, Material material)
        {
            material.SetFloat(OUTLINE_THICKNESS_ID, this._outlineThickness);
            material.SetFloat(OUTLINE_DEPTH_MULTIPLIER_ID, this._outlineDepthMultiplier);
            material.SetFloat(OUTLINE_DEPTH_BIAS_ID, this._outlineDepthBias);
            material.SetColor(OUTLINE_COLOR_ID, this._outlineColor);
        }
    }
}