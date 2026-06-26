using UnityEngine;

[ExecuteAlways]
[DisallowMultipleComponent]
public class StencilEffectMaterialController : MonoBehaviour
{
    [Header("Materials")]
    [Tooltip("Material de S_Suspect_Hologram_Reader.")]
    [SerializeField] private Material hologramMaterial;

    [Tooltip("Material de S_Suspect_Outline_Reader.")]
    [SerializeField] private Material outlineMaterial;

    [Tooltip("Material de S_SuspiciousItem_Reader.")]
    [SerializeField] private Material itemMaterial;

    [Header("Suspect Hologram Reader")]
    [Tooltip("Color principal del cuerpo holografico. Escribe _HologramColor.")]
    [SerializeField] private Color hologramColor = new Color(0f, 1f, 0.9750416f, 0f);

    [Tooltip("Transparencia del holograma. Escribe _Alpha.")]
    [Range(0f, 1f)]
    [SerializeField] private float hologramAlpha = 0.3f;

    [Tooltip("Color del brillo Fresnel del holograma. Escribe _FresnelColor.")]
    [SerializeField] private Color hologramFresnelColor = new Color(0.5481933f, 0.9113874f, 0.9150943f, 0f);

    [Tooltip("Intensidad del brillo Fresnel del holograma. Escribe _FresnelIntensity.")]
    [Range(0f, 8f)]
    [SerializeField] private float hologramFresnelIntensity = 1.35f;

    [Header("Suspect Outline Reader")]
    [Tooltip("Color del contorno del sospechoso. Escribe _OutlineColor.")]
    [SerializeField] private Color outlineColor = new Color(0.07075471f, 1f, 0.9465557f, 0f);

    [Tooltip("Transparencia del contorno. Escribe _OutlineAlpha.")]
    [Range(0f, 1f)]
    [SerializeField] private float outlineAlpha = 0.85f;

    [Tooltip("Intensidad emissiva del contorno. Escribe _EmissionIntensity.")]
    [Range(0f, 8f)]
    [SerializeField] private float outlineEmissionIntensity = 1.94f;

    [Header("Suspicious Item Reader")]
    [Tooltip("Color del objeto interno sospechoso. Escribe _ItemColor.")]
    [SerializeField] private Color itemColor = new Color(0.8301887f, 0.1135636f, 0.1135636f, 0f);

    [Tooltip("Transparencia del objeto interno. Escribe _ItemAlpha.")]
    [Range(0f, 1f)]
    [SerializeField] private float itemAlpha = 0.9f;

    [Tooltip("Intensidad emissiva del objeto interno. Escribe _EmissionIntensity.")]
    [Range(0f, 8f)]
    [SerializeField] private float itemEmissionIntensity = 1f;

    [Header("Runtime")]
    [Tooltip("Si esta activo, reenvia los valores cada frame para se puedan tocar en Play Mode y ver el cambio en runtime.")]
    [SerializeField] private bool applyEveryFrame = true;

    private static readonly int HologramColor = Shader.PropertyToID("_HologramColor");
    private static readonly int Alpha = Shader.PropertyToID("_Alpha");
    private static readonly int FresnelColor = Shader.PropertyToID("_FresnelColor");
    private static readonly int FresnelIntensity = Shader.PropertyToID("_FresnelIntensity");
    private static readonly int OutlineColor = Shader.PropertyToID("_OutlineColor");
    private static readonly int OutlineAlpha = Shader.PropertyToID("_OutlineAlpha");
    private static readonly int EmissionIntensity = Shader.PropertyToID("_EmissionIntensity");
    private static readonly int ItemColor = Shader.PropertyToID("_ItemColor");
    private static readonly int ItemAlpha = Shader.PropertyToID("_ItemAlpha");

    private void Reset()
    {
        AutoFindMaterialsByName();
        ApplyMaterialValues();
    }

    private void OnEnable()
    {
        ApplyMaterialValues();
    }

    private void OnValidate()
    {
        ClampValues();
        ApplyMaterialValues();
    }

    private void Update()
    {
        if (applyEveryFrame)
            ApplyMaterialValues();
    }

    [ContextMenu("Apply Material Values")]
    public void ApplyMaterialValues()
    {
        ClampValues();

        SetColor(hologramMaterial, HologramColor, hologramColor);
        SetFloat(hologramMaterial, Alpha, hologramAlpha);
        SetColor(hologramMaterial, FresnelColor, hologramFresnelColor);
        SetFloat(hologramMaterial, FresnelIntensity, hologramFresnelIntensity);

        SetColor(outlineMaterial, OutlineColor, outlineColor);
        SetFloat(outlineMaterial, OutlineAlpha, outlineAlpha);
        SetFloat(outlineMaterial, EmissionIntensity, outlineEmissionIntensity);

        SetColor(itemMaterial, ItemColor, itemColor);
        SetFloat(itemMaterial, ItemAlpha, itemAlpha);
        SetFloat(itemMaterial, EmissionIntensity, itemEmissionIntensity);
    }

    [ContextMenu("Auto Find Materials By Name")]
    public void AutoFindMaterialsByName()
    {
        Material[] materials = Resources.FindObjectsOfTypeAll<Material>();

        for (int i = 0; i < materials.Length; i++)
        {
            Material material = materials[i];

            if (material == null)
                continue;

            if (hologramMaterial == null && material.name == "M_Suspect_Hologram_Reader")
                hologramMaterial = material;
            else if (outlineMaterial == null && material.name == "M_Suspect_Outline_Reader")
                outlineMaterial = material;
            else if (itemMaterial == null && material.name == "M_SuspiciousItem_Reader")
                itemMaterial = material;
        }
    }

    private void ClampValues()
    {
        hologramAlpha = Mathf.Clamp01(hologramAlpha);
        hologramFresnelIntensity = Mathf.Max(0f, hologramFresnelIntensity);
        outlineAlpha = Mathf.Clamp01(outlineAlpha);
        outlineEmissionIntensity = Mathf.Max(0f, outlineEmissionIntensity);
        itemAlpha = Mathf.Clamp01(itemAlpha);
        itemEmissionIntensity = Mathf.Max(0f, itemEmissionIntensity);
    }

    private static void SetColor(Material material, int propertyId, Color value)
    {
        if (material != null && material.HasProperty(propertyId))
            material.SetColor(propertyId, value);
    }

    private static void SetFloat(Material material, int propertyId, float value)
    {
        if (material != null && material.HasProperty(propertyId))
            material.SetFloat(propertyId, value);
    }
}
