namespace RSPostProcessing
{
    using UnityEngine;

    [ExecuteInEditMode]
    [AddComponentMenu("RSPostProcessing/Sobel Outline")]
    public class SobelOutline : CameraPostEffect
    {
        private static readonly int OUTLINE_THICKNESS_ID = Shader.PropertyToID("_OutlineThickness");
        private static readonly int OUTLINE_COLOR_ID = Shader.PropertyToID("_OutlineColor");
        private static readonly int OUTLINE_DEPTH_MULTIPLIER_ID = Shader.PropertyToID("_OutlineDepthMultiplier");
        private static readonly int OUTLINE_DEPTH_BIAS_ID = Shader.PropertyToID("_OutlineDepthBias");
        private static readonly int OUTLINE_NORMAL_MULTIPLIER_ID = Shader.PropertyToID("_OutlineNormalMultiplier");
        private static readonly int OUTLINE_NORMAL_BIAS_ID = Shader.PropertyToID("_OutlineNormalBias");

        [Space(10f)]
        [SerializeField, Min(1)]
        private int _outlineThickness = 3;
        [SerializeField]
        private Color _outlineColor = Color.black;

        [Space(10f)]
        [SerializeField]
        private float _outlineDepthMultiplier = 1f;
        [SerializeField]
        private float _outlineDepthBias = 1f;
        
        [Space(10f)]
        [SerializeField]
        private float _outlineNormalMultiplier = 1f;
        [SerializeField]
        private float _outlineNormalBias = 1f;

        protected override string ShaderName => "RSPostProcessing/Sobel Outline";
        
        protected override void OnBeforeRenderImage(RenderTexture source, RenderTexture destination, Material material)
        {
            material.SetFloat(OUTLINE_THICKNESS_ID, this._outlineThickness);
            material.SetColor(OUTLINE_COLOR_ID, this._outlineColor);
            material.SetFloat(OUTLINE_DEPTH_MULTIPLIER_ID, this._outlineDepthMultiplier);
            material.SetFloat(OUTLINE_DEPTH_BIAS_ID, this._outlineDepthBias);
            material.SetFloat(OUTLINE_NORMAL_MULTIPLIER_ID, this._outlineNormalMultiplier);
            material.SetFloat(OUTLINE_NORMAL_BIAS_ID, this._outlineNormalBias);
        }
    }
}