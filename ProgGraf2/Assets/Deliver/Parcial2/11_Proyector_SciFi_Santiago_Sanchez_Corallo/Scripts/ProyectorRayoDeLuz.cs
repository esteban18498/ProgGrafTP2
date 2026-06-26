using UnityEngine;

public class ProyectorRayoDeLuz : MonoBehaviour
{
    [Header("Rayo de Luz")]
    public Material rayoDeLuzMaterial;

    private static readonly int LightTexture = Shader.PropertyToID("_ShadowTex");
    private static readonly int GradientTexture = Shader.PropertyToID("_FallOffTex");
    private static readonly int LightMaskPower = Shader.PropertyToID("_MaskPower");
    private static readonly int LightMaskIntensity = Shader.PropertyToID("_MaskIntensity");
    private static readonly int LightColor = Shader.PropertyToID("_Color");

    [Header("Rayo de sombra")]
    public Material rayoDeSombraMaterial;

    private static readonly int ShadowTexture = Shader.PropertyToID("_ShadowTex");
    private static readonly int ShadowMaskPower = Shader.PropertyToID("_MaskPower");
    private static readonly int ShadowMaskIntensity = Shader.PropertyToID("_MaskIntensity");


    public Texture lightTexture = null;
    public Texture shadowTexture = null;
    public Texture gradientTexture = null;
    [Range(-10.0f, 100.0f)]
    public float lightMaskPower = 4.0f;
    [Range(-10.0f, 100.0f)]
    public float lightMaskIntensity = 6.0f;
    [Range(-10.0f, 100.0f)]
    public float shadowMaskPower = 1.15f;
    [Range(-10.0f, 100.0f)]
    public float shadowMaskIntensity = 6.0f;
    public Color lightColor = Color.white;

    private void Update()
    {
        ApplyShaderValues();
    }

    [ContextMenu("Apply Shader Values")]
    private void ApplyShaderValues()
    {
        if (rayoDeLuzMaterial == null)
            rayoDeLuzMaterial = GetComponent<Renderer>().material;

        if (rayoDeSombraMaterial == null)
            rayoDeSombraMaterial = GetComponent<Renderer>().material;

        rayoDeLuzMaterial.SetTexture(LightTexture, lightTexture);
        rayoDeLuzMaterial.SetTexture(GradientTexture, gradientTexture);
        rayoDeLuzMaterial.SetFloat(LightMaskPower, lightMaskPower);
        rayoDeLuzMaterial.SetFloat(LightMaskIntensity, lightMaskIntensity);
        rayoDeLuzMaterial.SetColor(LightColor, lightColor);

        rayoDeSombraMaterial.SetTexture(ShadowTexture, shadowTexture);
        rayoDeSombraMaterial.SetFloat(ShadowMaskPower, shadowMaskPower);
        rayoDeSombraMaterial.SetFloat(ShadowMaskIntensity, shadowMaskIntensity);
    }
}
