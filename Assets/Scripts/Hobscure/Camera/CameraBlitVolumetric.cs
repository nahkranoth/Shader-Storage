using UnityEngine;
using System.Collections;
using UnityEngine.Rendering;

[RequireComponent(typeof(Camera))]
public class CameraBlitVolumetric : MonoBehaviour
{
    [SerializeField]
    private Texture2D noiseOffsetTexture;

    [SerializeField]
    private Material material;

    [SerializeField, Range(10, 200)]
    private int width = 100;

    [SerializeField, Range(10, 200)]
    private int height = 100;

    private Camera cam;

    private void Awake()
    {
        Shader.SetGlobalTexture("_NoiseOffsets", this.noiseOffsetTexture);

        int lowResRenderTarget = Shader.PropertyToID("_LowResRenderTarget");

        CommandBuffer cb = new CommandBuffer();

        cb.GetTemporaryRT(lowResRenderTarget, this.width, this.height, 0, FilterMode.Trilinear, RenderTextureFormat.ARGB32);

        // Blit the low-res texture into itself, to re-draw it with the current material
        cb.Blit(lowResRenderTarget, lowResRenderTarget, this.material);

        // Blit the low-res texture into the camera's target render texture, effectively rendering it to the entire screen
        cb.Blit(lowResRenderTarget, BuiltinRenderTextureType.CameraTarget);

        cb.ReleaseTemporaryRT(lowResRenderTarget);

        cam = this.GetComponent<Camera>();
        // Tell the camera to execute our CommandBuffer before the forward opaque pass - that is, just before normal geometry starts rendering
        cam.AddCommandBuffer(CameraEvent.BeforeForwardOpaque, cb);
    }

    void Update()
    {
        material.SetFloat("_Seed", Time.time);
        //cam.transform.Rotate(new Vector3(0f, 1f, 0f));
    }

    private void OnPreRender()
    {
        Shader.SetGlobalVector("_CamPos", this.transform.position);
        Shader.SetGlobalVector("_CamRight", this.transform.right);
        Shader.SetGlobalVector("_CamUp", this.transform.up);
        Shader.SetGlobalVector("_CamForward", this.transform.forward);
        Shader.SetGlobalFloat("_AspectRatio", (float)Screen.width / (float)Screen.height);
        Shader.SetGlobalFloat("_FieldOfView", Mathf.Tan(Camera.main.fieldOfView * Mathf.Deg2Rad * 0.5f) * 2f);
    }
}