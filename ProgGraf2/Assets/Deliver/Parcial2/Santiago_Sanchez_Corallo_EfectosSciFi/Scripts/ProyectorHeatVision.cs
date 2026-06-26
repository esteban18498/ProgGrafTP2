using UnityEngine;

public class ProyectorHeatVision : MonoBehaviour
{
    public Material heatVisionMaterial;

    private static readonly int Temperature = Shader.PropertyToID("_Temperature");
    private static readonly int HeatVisionBias = Shader.PropertyToID("_HeatVisionBias");
    private static readonly int HeatVisionScale = Shader.PropertyToID("_HeatVisionScale");
    private static readonly int HeatVisionPower = Shader.PropertyToID("_HeatVisionPower");
    private static readonly int OutlineWidth = Shader.PropertyToID("_OutlineWidth");

    [Range(-10.0f, 100.0f)]
    public float TemperatureValue = 55.0f;
    [Range(-10.0f, 100.0f)]
    public float heatVisionBiasValue = -1.15f;
    [Range(-10.0f, 100.0f)]
    public float heatVisionScaleValue = 2.37f;
    [Range(-10.0f, 100.0f)]
    public float heatVisionPowerValue = 1.1f;
    [Range(-10.0f, 100.0f)]
    public float outlineWidthValue = 0.01f;

    private void Update()
    {
        ApplyShaderValues();
    }

    [ContextMenu("Apply Shader Values")]
    private void ApplyShaderValues()
    {
        if (heatVisionMaterial == null)
            heatVisionMaterial = GetComponent<Renderer>().material;

        heatVisionMaterial.SetFloat(Temperature, TemperatureValue);
        heatVisionMaterial.SetFloat(HeatVisionBias, heatVisionBiasValue);
        heatVisionMaterial.SetFloat(HeatVisionScale, heatVisionScaleValue);
        heatVisionMaterial.SetFloat(HeatVisionPower, heatVisionPowerValue);
        heatVisionMaterial.SetFloat(OutlineWidth, outlineWidthValue);
    }
}