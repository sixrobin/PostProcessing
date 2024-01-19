namespace RSPostProcessing
{
    using UnityEngine;

    [ExecuteInEditMode]
    [AddComponentMenu("RSPostProcessing/Fast Gaussian Blur")]
    public class FastGaussianBlur : CameraPostEffect
    {
        private enum DownSampleMode
        {
            [InspectorName("Off")]     OFF,
            [InspectorName("Half")]    HALF,
            [InspectorName("Quarter")] QUARTER,
        }
        
        [SerializeField, Range(0, 50)]
        private int iterations = 3;
        [SerializeField]
        private DownSampleMode _downSampleMode = DownSampleMode.QUARTER;
        
        protected override string ShaderName => "RSPostProcessing/Fast Gaussian Blur";

        protected override void OnBeforeRenderImage(RenderTexture source, RenderTexture destination, Material material)
        {
        }

        protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            RenderTexture renderTexture1;
            RenderTexture renderTexture2;

            switch (_downSampleMode)
            {
                case DownSampleMode.HALF:
                    renderTexture1 = RenderTexture.GetTemporary(source.width / 2, source.height / 2);
                    renderTexture2 = RenderTexture.GetTemporary(source.width / 2, source.height / 2);
                    Graphics.Blit(source, renderTexture1);
                    break;
                case DownSampleMode.QUARTER:
                    renderTexture1 = RenderTexture.GetTemporary(source.width / 4, source.height / 4);
                    renderTexture2 = RenderTexture.GetTemporary(source.width / 4, source.height / 4);
                    Graphics.Blit(source, renderTexture1, Material, 0);
                    break;
                case DownSampleMode.OFF:
                default:
                    renderTexture1 = RenderTexture.GetTemporary(source.width, source.height);
                    renderTexture2 = RenderTexture.GetTemporary(source.width, source.height);
                    Graphics.Blit(source, renderTexture1);
                    break;
            }

            for (int i = 0; i < iterations; ++i)
            {
                Graphics.Blit(renderTexture1, renderTexture2, Material, 1);
                Graphics.Blit(renderTexture2, renderTexture1, Material, 2);
            }

            Graphics.Blit(renderTexture1, destination);

            RenderTexture.ReleaseTemporary(renderTexture1);
            RenderTexture.ReleaseTemporary(renderTexture2);
        }
    }
}