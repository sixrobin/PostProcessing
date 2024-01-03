namespace RSPostProcessing
{
    using UnityEngine;

    [ExecuteInEditMode]
    [AddComponentMenu("RSPostProcessing/VHS")]
    public class VHS : CameraPostEffect
    {
        protected override string ShaderName => "RSPostProcessing/VHS";

        protected override void OnBeforeRenderImage(RenderTexture source, RenderTexture destination, Material material)
        {
        }
    }
}