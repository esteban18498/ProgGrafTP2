using UnityEngine;

public class ProyectorXRay : MonoBehaviour
{
    public Material xRayMaterial;

    private static readonly int XRayBias = Shader.PropertyToID("_XRayBias");
    private static readonly int XRayScale = Shader.PropertyToID("_XRayScale");
    private static readonly int XRayPower = Shader.PropertyToID("_XRayPower");
    private static readonly int XRayColor = Shader.PropertyToID("_XRayColor");
    private static readonly int XRayIntensity = Shader.PropertyToID("_XRayIntensity");
    private static readonly int OutlineWidth = Shader.PropertyToID("_OutlineWidth");

    [Range(-10.0f, 100.0f)]
    public float xRayBias = 0.0f;
    [Range(-10.0f, 100.0f)]
    public float xRayScale = 1.0f;
    [Range(-10.0f, 100.0f)]
    public float xRayPower = 1.0f;
    [Range(-10.0f, 100.0f)]
    public float xRayIntensity = 1.0f;
    [Range(-10.0f, 100.0f)]
    public float outlineWidth = 1.0f;

    public Color xRayColor = Color.white;

    private void Update()
    {
        ApplyShaderValues();
    }

    [ContextMenu("Apply Shader Values")]
    private void ApplyShaderValues()
    {
        if (xRayMaterial == null)
            xRayMaterial = GetComponent<Renderer>().material;

        xRayMaterial.SetFloat(XRayBias, xRayBias);
        xRayMaterial.SetFloat(XRayScale, xRayScale);
        xRayMaterial.SetFloat(XRayPower, xRayPower);
        xRayMaterial.SetColor(XRayColor, xRayColor);
        xRayMaterial.SetFloat(XRayIntensity, xRayIntensity);
        xRayMaterial.SetFloat(OutlineWidth, outlineWidth);
    }
}