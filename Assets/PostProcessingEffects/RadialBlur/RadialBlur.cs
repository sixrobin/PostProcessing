namespace RSPostProcessing
{
    using UnityEngine;

    [ExecuteInEditMode]
    [DisallowMultipleComponent]
    [AddComponentMenu("RSPostProcessing/Radial Blur")]
    public class RadialBlur : CameraPostEffect
    {
        private static readonly int SAMPLES_ID = Shader.PropertyToID("_Samples");
        private static readonly int STRENGTH_ID = Shader.PropertyToID("_Strength");
        private static readonly int CENTER_X_ID = Shader.PropertyToID("_CenterX");
        private static readonly int CENTER_Y_ID = Shader.PropertyToID("_CenterY");
        
        [SerializeField, Range(0, 50)]
        private int _samples = 25;
        [SerializeField, Range(0f, 1f)]
        private float _strength = 0.25f;
        [SerializeField]
        private Vector2 _center = new Vector2(0.5f, 0.5f);

        protected override string ShaderName => "RSPostProcessing/Radial Blur";

        protected override void OnBeforeRenderImage(RenderTexture source, RenderTexture destination, Material material)
        {
            material.SetInt(SAMPLES_ID, _samples + 1);
            material.SetFloat(STRENGTH_ID, _strength);
            material.SetFloat(CENTER_X_ID, _center.x);
            material.SetFloat(CENTER_Y_ID, _center.y);
        }
    }
}