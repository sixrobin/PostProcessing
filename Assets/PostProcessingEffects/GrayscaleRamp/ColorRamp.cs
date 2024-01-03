namespace RSPostProcessing
{
    using UnityEngine;

    [ExecuteInEditMode]
    [AddComponentMenu("RSPostProcessing/Color Ramp")]
    public class ColorRamp : CameraPostEffect
    {
        private static readonly int RAMP_TEX_ID = Shader.PropertyToID("_RampTex");
        private static readonly int RAMP_OFFSET_ID = Shader.PropertyToID("_RampOffset");
        private static readonly int WEIGHT_ID = Shader.PropertyToID("_Weight");
        
        [SerializeField]
        private Texture2D _textureRamp = null;
        [SerializeField, Range(-1f, 1f)]
        private float _offset = 0f;
        [SerializeField, Range(0f, 1f)]
        private float _weight = 1f;

        public bool Inverted;
        private Texture2D _initRamp;
        
        protected override string ShaderName => "RSPostProcessing/Color Ramp";

        public Texture2D TextureRamp => _textureRamp;

        public float Offset
        {
            get => _offset;
            set => _offset = Mathf.Clamp(value, -1f, 1f);
        }

        public void SetRamp(Texture2D ramp)
        {
            _textureRamp = ramp;
        }

        public void ResetRamp()
        {
            _textureRamp = _initRamp;
        }

        private void Awake()
        {
            _initRamp = _textureRamp;
        }

        protected override void OnBeforeRenderImage(RenderTexture source, RenderTexture destination, Material material)
        {
            material.SetTexture(RAMP_TEX_ID, Inverted && _textureRamp != null ? FlipX(_textureRamp) : _textureRamp);
            material.SetFloat(RAMP_OFFSET_ID, _offset);
            material.SetFloat(WEIGHT_ID, _weight);
        }
        
        private static Texture2D FlipX(Texture2D original)
        {
            UnityEngine.Assertions.Assert.IsTrue(original.isReadable, $"Cannot flip Texture2D {original.name} on X since Read/Write has not been checked.");

            int w = original.width;
            int h = original.height;

            Texture2D flipped = new Texture2D(w, h)
            {
                wrapModeU = TextureWrapMode.Clamp
            };

            for (int x = 0; x < w; ++x)
                for (int y = 0; y < h; ++y)
                    flipped.SetPixel(w - x - 1, y, original.GetPixel(x, y));

            flipped.Apply();
            return flipped;
        }
    }
}