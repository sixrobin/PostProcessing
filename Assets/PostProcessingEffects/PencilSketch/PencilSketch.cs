namespace RSPostProcessing
{
    using UnityEngine;
    using UnityEngine.Rendering;

    [ExecuteInEditMode]
    [AddComponentMenu("RSPostProcessing/Pencil Sketch")]
    public class PencilSketch : CameraPostEffect
    {
        private static readonly int CROSSHATCHES_ID = Shader.PropertyToID("_Crosshatches");
        private static readonly int MAIN_TEX_DISTORTION_ID = Shader.PropertyToID("_MainTexDistortion");
        private static readonly int MAIN_TEX_DISTORTION_ST_ID = Shader.PropertyToID("_MainTexDistortion_ST");
        private static readonly int MAIN_TEX_DISTORTION_INTENSITY_ID = Shader.PropertyToID("_MainTexDistortionIntensity");
        private static readonly int POSTERIZATION_ID = Shader.PropertyToID("_Posterization");
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
        [SerializeField, Min(1)]
        private int _posterization = 8;
        [SerializeField]
        private Texture _crosshatches = null;
        
        [Header("DISTORTION")]
        [SerializeField]
        private Texture2D _distortionNoise = null;
        [SerializeField]
        private Vector2 _distortionScale = Vector2.one;
        [SerializeField, Range(0f, 0.01f)]
        private float _distortionIntensity = 0.005f;
        
        [Header("OUTLINE")]
        [SerializeField]
        private float _outlineDepthMultiplier = 1f;
        [SerializeField]
        private float _outlineDepthBias = 1f;
        [Space(10f)]
        [SerializeField]
        private float _outlineNormalMultiplier = 1f;
        [SerializeField]
        private float _outlineNormalBias = 1f;

        protected override string ShaderName => "RSPostProcessing/Pencil Sketch";

        protected override void OnBeforeRenderImage(RenderTexture source, RenderTexture destination, Material material)
        {
            material.SetTexture(CROSSHATCHES_ID, _crosshatches);
            material.SetTexture(MAIN_TEX_DISTORTION_ID, _distortionNoise);
            material.SetVector(MAIN_TEX_DISTORTION_ST_ID, new Vector4(_distortionScale.x, _distortionScale.y, 0f, 0f));
            material.SetFloat(MAIN_TEX_DISTORTION_INTENSITY_ID, _distortionIntensity);
            material.SetFloat(POSTERIZATION_ID, _posterization);
            material.SetFloat(OUTLINE_THICKNESS_ID, Mathf.RoundToInt(_outlineThickness * (Screen.width / 1080f)));
            material.SetColor(OUTLINE_COLOR_ID, _outlineColor);
            material.SetFloat(OUTLINE_DEPTH_MULTIPLIER_ID, _outlineDepthMultiplier);
            material.SetFloat(OUTLINE_DEPTH_BIAS_ID, _outlineDepthBias);
            material.SetFloat(OUTLINE_NORMAL_MULTIPLIER_ID, _outlineNormalMultiplier);
            material.SetFloat(OUTLINE_NORMAL_BIAS_ID, _outlineNormalBias);
        }
    }
}