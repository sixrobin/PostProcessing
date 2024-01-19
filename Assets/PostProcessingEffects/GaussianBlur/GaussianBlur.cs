namespace RSPostProcessing
{
    using UnityEngine;

    [ExecuteInEditMode]
    [AddComponentMenu("RSPostProcessing/Gaussian Blur")]
    public class GaussianBlur : CameraPostEffect
    {
        [SerializeField, Range(0, 50)]
        private int iterations = 3;
        
        protected override string ShaderName => "RSPostProcessing/Gaussian Blur";

        protected override void OnBeforeRenderImage(RenderTexture source, RenderTexture destination, Material material)
        {
        }

        protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            RenderTexture renderTexture = source;
            RenderTexture blit = RenderTexture.GetTemporary(source.width, source.height);
            
            for (int i = 0; i < iterations; i++)
            {
                Graphics.SetRenderTarget(blit);
                GL.Clear(true, true, Color.black);
                Graphics.Blit(renderTexture, blit, Material);
                
                Graphics.SetRenderTarget(renderTexture);
                GL.Clear(true, true, Color.black);
                Graphics.Blit(blit, renderTexture, Material);
            }

            Graphics.Blit(source, destination, Material, Pass);
            RenderTexture.ReleaseTemporary(blit);
        }
    }
}