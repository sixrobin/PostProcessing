namespace RSPostProcessing
{
    using UnityEngine;
    
    [RequireComponent(typeof(Camera))]
    public abstract class CameraPostEffect : MonoBehaviour
    {
        [SerializeField]
        private Shader _shader = null;

        private Material _material;

        protected abstract string ShaderName { get; }

        protected Material Material
        {
            get
            {
                if (_shader == null)
                {
                    Cleanup();
                    return null;
                }

                if (_material == null || _material.shader != _shader)
                    _material = new Material(_shader) { hideFlags = HideFlags.HideAndDontSave };

                return _material;
            }
        }

        protected virtual int Pass => -1;
        
        private bool FindShader()
        {
            if (!string.IsNullOrEmpty(ShaderName))
                _shader = Shader.Find(ShaderName);

            return _shader != null;
        }

        private void Cleanup()
        {
            if (_material != null)
            {
                #if UNITY_EDITOR
                DestroyImmediate(_material);
                #else
                Destroy(_material);
                #endif
            }
        }
        
        protected abstract void OnBeforeRenderImage(RenderTexture source, RenderTexture destination, Material material);
        
        protected virtual void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            if (Material == null)
                return;
            
            OnBeforeRenderImage(source, destination, Material);
            Graphics.Blit(source, destination, Material, Pass);
        }

        protected virtual void OnEnable()
        {
            if (_shader == null)
            {
                if (!FindShader())
                {
                    enabled = false;
                    return;
                }
            }

            if (!_shader.isSupported)
                enabled = false;
        }

        protected virtual void OnDisable()
        {
            Cleanup();
        }

        private void Reset()
        {
            if (_shader == null)
                FindShader();
        }
    }
}