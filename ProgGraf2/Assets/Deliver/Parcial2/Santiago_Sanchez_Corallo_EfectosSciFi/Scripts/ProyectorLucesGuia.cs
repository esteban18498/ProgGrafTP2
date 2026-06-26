using UnityEngine;

public class ProyectorLucesGuia : MonoBehaviour
{
    public Material lucesGuiaMaterial;

    private static readonly int BaseTexture = Shader.PropertyToID("_Texture");
    private static readonly int BaseColor = Shader.PropertyToID("_Color");

    public Texture baseTexture = null;
    public Color baseColor = Color.white;

    private void Update()
    {
        ApplyShaderValues();
    }

    [ContextMenu("Apply Shader Values")]
    private void ApplyShaderValues()
    {
        if (lucesGuiaMaterial == null)
            lucesGuiaMaterial = GetComponent<Renderer>().material;

        lucesGuiaMaterial.SetTexture(BaseTexture, baseTexture);
        lucesGuiaMaterial.SetColor(BaseColor, baseColor);
    }
}
