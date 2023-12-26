namespace RSPostProcessing
{
    using UnityEngine;

    [ExecuteInEditMode]
    [AddComponentMenu("RSPostProcessing/Screen Guide")]
    public class ScreenGuide : CameraPostEffect
    {
        private const string ALWAYS_SHOW_CENTER_KEYWORD = "ALWAYSSHOWCENTER";
        private static readonly int LINES_X_ID = Shader.PropertyToID("_LinesX");
        private static readonly int LINES_Y_ID = Shader.PropertyToID("_LinesY");
        private static readonly int COLOR_X_ID = Shader.PropertyToID("_ColorX");
        private static readonly int COLOR_Y_ID = Shader.PropertyToID("_ColorY");
        private static readonly int SCALE_ID = Shader.PropertyToID("_LineScale");
        
        [Header("SETTINGS")]
        [SerializeField]
        private bool _alwaysShowCenter = false;
        [SerializeField, Range(0, 10)]
        private int _horizontalLines = 3;
        [SerializeField, Range(0, 10)]
        private int _verticalLines = 3;

        [Header("STYLE")]
        [SerializeField]
        private Color _colorX = Color.red;
        [SerializeField]
        private Color _colorY = Color.green;
        
        [SerializeField, Range(1f, 10f)]
        private float _scale = 1;
        
        protected override string ShaderName => "RSPostProcessing/Screen Guide";

        protected override void OnBeforeRenderImage(RenderTexture source, RenderTexture destination, Material material)
        {
            if (_alwaysShowCenter)
                Material.EnableKeyword(ALWAYS_SHOW_CENTER_KEYWORD);
            else
                Material.DisableKeyword(ALWAYS_SHOW_CENTER_KEYWORD);

            Material.SetFloat(LINES_X_ID, _verticalLines);
            Material.SetFloat(LINES_Y_ID, _horizontalLines);
            Material.SetColor(COLOR_X_ID, _colorX);
            Material.SetColor(COLOR_Y_ID, _colorY);
            Material.SetFloat(SCALE_ID, _scale);
        }
    }
}