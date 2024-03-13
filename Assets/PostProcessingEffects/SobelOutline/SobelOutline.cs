namespace RSPostProcessing
{
    using UnityEngine;
    using UnityEngine.Rendering;

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

        [Header("GENERAL")]
        [SerializeField, Min(1)]
        private int _outlineThickness = 3;
        [SerializeField]
        private Color _outlineColor = Color.black;

        [Header("DEPTH")]
        [SerializeField]
        private float _outlineDepthMultiplier = 1f;
        [SerializeField]
        private float _outlineDepthBias = 1f;
        
        [Header("NORMAL")]
        [SerializeField]
        private float _outlineNormalMultiplier = 1f;
        [SerializeField]
        private float _outlineNormalBias = 1f;

        [Header("DEBUG")]
        [SerializeField]
        private bool _debugDepth;
        [SerializeField]
        private bool _debugNormal;

        private LocalKeyword _debugDepthKeyword;
        private LocalKeyword _debugNormalKeyword;
        
        protected override string ShaderName => "RSPostProcessing/Sobel Outline";

        protected override void OnBeforeRenderImage(RenderTexture source, RenderTexture destination, Material material)
        {
            material.SetFloat(OUTLINE_THICKNESS_ID, _outlineThickness);
            material.SetColor(OUTLINE_COLOR_ID, _outlineColor);
            material.SetFloat(OUTLINE_DEPTH_MULTIPLIER_ID, _outlineDepthMultiplier);
            material.SetFloat(OUTLINE_DEPTH_BIAS_ID, _outlineDepthBias);
            material.SetFloat(OUTLINE_NORMAL_MULTIPLIER_ID, _outlineNormalMultiplier);
            material.SetFloat(OUTLINE_NORMAL_BIAS_ID, _outlineNormalBias);

            _debugDepthKeyword = new LocalKeyword(Material.shader, "DEBUG_DEPTH");
            _debugNormalKeyword = new LocalKeyword(Material.shader, "DEBUG_NORMAL");
            material.SetKeyword(_debugDepthKeyword, _debugDepth);
            material.SetKeyword(_debugNormalKeyword, _debugNormal);
        }
    }
}