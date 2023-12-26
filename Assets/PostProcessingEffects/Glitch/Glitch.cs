namespace RSPostProcessing
{
    using UnityEngine;

    [ExecuteInEditMode]
    [AddComponentMenu("RSPostProcessing/Glitch")]
    public class Glitch : CameraPostEffect 
    {
	    private static readonly int INTENSITY_ID = Shader.PropertyToID("_Intensity");
	    private static readonly int COLOR_INTENSITY_ID = Shader.PropertyToID("_ColorIntensity");
	    private static readonly int DISPLACEMENT_TEXTURE_ID = Shader.PropertyToID("_DispTex");
	    private static readonly int FILTER_RADIUS_ID = Shader.PropertyToID("filter_radius");
	    private static readonly int DIRECTION_ID = Shader.PropertyToID("direction");
	    private static readonly int FLIP_UP_ID = Shader.PropertyToID("flip_up");
	    private static readonly int FLIP_DOWN_ID = Shader.PropertyToID("flip_down");
	    private static readonly int DISPLACE_ID = Shader.PropertyToID("displace");
	    private static readonly int SCALE_ID = Shader.PropertyToID("scale");
	    
        [SerializeField, Range(0f, 1f)]
        private float _intensity = 1f;
	    [SerializeField, Range(0f, 1f)]
	    private float _flipIntensity = 1f;
	    [SerializeField, Range(0f, 1f)]
	    private float _colorIntensity = 1f;
	    [SerializeField]
	    private Texture2D _displacementMap = null;

	    private float _glitchUp;
	    private float _glitchDown;
	    private float _flicker;
	    private float _glitchUpTime = 0.05f;
	    private float _glitchDownTime = 0.05f;
	    private float _flickerTime = 0.5f;
	    
	    protected override string ShaderName => "RSPostProcessing/Glitch";
	    
	    public void IncreaseIntensity(float intensityIncrease, float flipIncrease, float colorIncrease)
	    {
		    _intensity = Mathf.Clamp01(_intensity + intensityIncrease);
		    _flipIntensity += Mathf.Clamp01(_intensity + flipIncrease);
		    _colorIntensity += Mathf.Clamp01(_intensity + colorIncrease);
	    }
	    
	    public void DecreaseIntensity(float intensityDecrease, float flipDecrease, float colorDecrease)
	    {
		    _intensity = Mathf.Clamp01(_intensity - intensityDecrease);
		    _flipIntensity += Mathf.Clamp01(_intensity - flipDecrease);
		    _colorIntensity += Mathf.Clamp01(_intensity - colorDecrease);
	    }

	    public void ResetValues()
	    {
		    _intensity = 0f;
		    _flipIntensity = 0f;
		    _colorIntensity = 0f;
	    }

	    protected override void OnBeforeRenderImage(RenderTexture source, RenderTexture destination, Material material)
	    {
		    material.SetFloat(INTENSITY_ID, _intensity);
            material.SetFloat(COLOR_INTENSITY_ID, _colorIntensity);
		    material.SetTexture(DISPLACEMENT_TEXTURE_ID, _displacementMap);
        
            _flicker += Time.deltaTime * _colorIntensity;
            _glitchUp += Time.deltaTime * _flipIntensity;
            _glitchDown += Time.deltaTime * _flipIntensity;

            if (_flicker > _flickerTime)
		    {
			    material.SetFloat(FILTER_RADIUS_ID, Random.Range(-3f, 3f) * _colorIntensity);
			    material.SetVector(DIRECTION_ID, Quaternion.AngleAxis(Random.Range(0f, 360f) * _colorIntensity, Vector3.forward) * Vector4.one);
                _flicker = 0f;
			    _flickerTime = Random.value;
		    }

            if (_colorIntensity == 0f)
	            material.SetFloat(FILTER_RADIUS_ID, 0f);
        
            if (_glitchUp > _glitchUpTime)
		    {
			    material.SetFloat(FLIP_UP_ID, Random.value < 0.1f * _flipIntensity ? Random.value * _flipIntensity : 0f);
			    _glitchUp = 0f;
			    _glitchUpTime = Random.value * 0.1f;
		    }

            if (_flipIntensity == 0f)
	            material.SetFloat(FLIP_UP_ID, 0f);

            if (_glitchDown > _glitchDownTime)
		    {
			    material.SetFloat(FLIP_DOWN_ID, Random.value < _flipIntensity * 0.1f ? 1f - Random.value * _flipIntensity : 1f);
			    _glitchDown = 0f;
			    _glitchDownTime = Random.value * 0.1f;
            }

            if (_flipIntensity == 0f)
	            material.SetFloat(FLIP_DOWN_ID, 1f);

            if (Random.value < 0.05f * _intensity)
		    {
			    material.SetFloat(DISPLACE_ID, Random.value * _intensity);
			    material.SetFloat(SCALE_ID, 1f - Random.value * _intensity);
            }
            else
		    {
			    material.SetFloat(DISPLACE_ID, 0f);
		    }
	    }
    }
}