namespace RSPostProcessing
{
    using UnityEngine;

    [ExecuteInEditMode]
    [AddComponentMenu("RSPostProcessing/Ripple")]
    public class Ripple : CameraPostEffect
    {
        private static readonly int GRAD_TEX_ID = Shader.PropertyToID("_GradTex");
        private static readonly int REFLECTION_ID = Shader.PropertyToID("_Reflection");
        private static readonly int PARAMS1_ID = Shader.PropertyToID("_Params1");
        private static readonly int PARAMS2_ID = Shader.PropertyToID("_Params2");
        
        private class Droplet
        {
            private readonly bool _timeScaleDependent;
            private Vector2 _position;
            private float _time;

            public Droplet()
            {
                _time = 1000f;
            }

            public Droplet(bool timeScaleDependent)
            {
                _time = 1000f;
                _timeScaleDependent = timeScaleDependent;
            }

            public void Reset(float screenX, float screenY)
            {
                _position = new Vector2(screenX, screenY);
                _time = 0f;
            }

            public void Update()
            {
                _time += _timeScaleDependent ? Time.deltaTime : Time.unscaledDeltaTime;
            }

            public Vector4 MakeShaderParameter(float aspect)
            {
                return new Vector4(_position.x * aspect, _position.y, _time, 0f);
            }
        }
        
        [SerializeField]
        private AnimationCurve _waveform = new AnimationCurve
        (
            new Keyframe(0.00f, 0.50f, 0f, 0f),
            new Keyframe(0.05f, 1.00f, 0f, 0f),
            new Keyframe(0.15f, 0.10f, 0f, 0f),
            new Keyframe(0.25f, 0.80f, 0f, 0f),
            new Keyframe(0.35f, 0.30f, 0f, 0f),
            new Keyframe(0.45f, 0.60f, 0f, 0f),
            new Keyframe(0.55f, 0.40f, 0f, 0f),
            new Keyframe(0.65f, 0.55f, 0f, 0f),
            new Keyframe(0.75f, 0.46f, 0f, 0f),
            new Keyframe(0.85f, 0.52f, 0f, 0f),
            new Keyframe(0.99f, 0.50f, 0f, 0f)
        );
        
        [SerializeField, Range(0.01f, 1f)]
        private float _refractionStrength = 0.5f;
        [SerializeField, Range(0.01f, 1f)]
        private float _reflectionStrength = 0.7f;
        [SerializeField, Range(1f, 3f)]
        private float _waveSpeed = 1.25f;
        [SerializeField]
        private Color _reflectionColor = Color.gray;
        [SerializeField]
        private bool _timeScaleDependent = false;

        private Camera _camera;
        private Droplet[] _droplets;
        private Texture2D _gradTexture;

        protected override string ShaderName => "RSPostProcessing/Ripple";
        
        private int _nextDropletIndex;

        private int NextDropletIndex
        {
            get => _nextDropletIndex;
            set => _nextDropletIndex = value % _droplets.Length;
        }

        public void RippleAtWorldPosition(Vector3 position)
        {
            Vector3 screenPosition = _camera.WorldToViewportPoint(position);
            Emit(screenPosition.x, screenPosition.y);
        }

        public void RippleAtWorldPosition(float x, float y)
        {
            RippleAtWorldPosition(new Vector3(x, y));
        }

        private void Initialize()
        {
            _camera = GetComponent<Camera>();

            _droplets = new Droplet[5]
            {
                new Droplet(_timeScaleDependent),
                new Droplet(_timeScaleDependent),
                new Droplet(_timeScaleDependent),
                new Droplet(_timeScaleDependent),
                new Droplet(_timeScaleDependent)
            };

            _gradTexture = new Texture2D(2048, 1, TextureFormat.Alpha8, false)
            {
                wrapMode = TextureWrapMode.Clamp,
                filterMode = FilterMode.Bilinear
            };

            for (int i = 0; i < _gradTexture.width; ++i)
            {
                float waveEval = _waveform.Evaluate(1f / _gradTexture.width * i);
                _gradTexture.SetPixel(i, 0, new Color(waveEval, waveEval, waveEval, waveEval));
            }

            _gradTexture.Apply();
            Material.SetTexture(GRAD_TEX_ID, _gradTexture);
        }

        private void Emit(float x, float y)
        {
            _droplets[NextDropletIndex++].Reset(x, y);
        }

        private void Start()
        {
            Initialize();
        }

        protected override void OnBeforeRenderImage(RenderTexture source, RenderTexture destination, Material material)
        {
            if (_droplets == null)
                return;
            
            for (int i = _droplets.Length - 1; i >= 0; --i)
            {
                _droplets[i].Update();
                material.SetVector($"_Drop{i + 1}", _droplets[i].MakeShaderParameter(_camera.aspect));
            }

            material.SetColor(REFLECTION_ID, _reflectionColor);
            material.SetVector(PARAMS1_ID, new Vector4(_camera.aspect, 1f, 1f / _waveSpeed, 0f));
            material.SetVector(PARAMS2_ID, new Vector4(1f, 1f / _camera.aspect, _refractionStrength, _reflectionStrength));
        }
    }
}