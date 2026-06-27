using System.Collections.Generic;
using UnityEngine;

[DisallowMultipleComponent]
public class StencilPulseScanner : MonoBehaviour
{
    [Header("Input")]
    [Tooltip("Tecla que dispara el pulso de deteccion.")]
    [SerializeField] private KeyCode scanKey = KeyCode.R;

    [Header("Pulse")]
    [Tooltip("Esfera visual con el material Stencil Scanner Writer. El script la escala desde cero hasta Max Radius.")]
    [SerializeField] private Transform pulseSphere;

    [Tooltip("Radio final del pulso en unidades de mundo.")]
    [SerializeField] private float maxRadius = 12f;

    [Tooltip("Velocidad base de expansion en unidades de mundo por segundo. Con Max Radius = 16 y Speed = 16, el pulso termina en aproximadamente un segundo.")]
    [Min(0.01f)]
    [SerializeField] private float expansionSpeed = 16f;

    [Tooltip("Multiplicador visual independiente por eje. X y Z controlan el alcance horizontal; Y aplasta o estira la esfera verticalmente. No modifica el radio de deteccion.")]
    [SerializeField] private Vector3 growthScale = new Vector3(1f, 0.33f, 1f);

    [Tooltip("Curva de crecimiento del radio. X es tiempo normalizado, Y es radio normalizado.")]
    [SerializeField] private AnimationCurve radiusCurve = AnimationCurve.EaseInOut(0f, 0f, 1f, 1f);

    [Header("Scanner Shader")]
    [Tooltip("Color/emision del pulso. Se envia por script a _PulseColor del shader S_StencilScanner_Writer.")]
    [SerializeField] private Color pulseColor = new Color(0f, 0.8396226f, 0.7392964f, 0f);

    [Tooltip("Transparencia base de toda la esfera. Se envia por script a _BaseAlpha.")]
    [Range(0f, 1f)]
    [SerializeField] private float baseAlpha = 0.2f;

    [Tooltip("Transparencia extra del borde Fresnel/rim de la esfera. Se envia por script a _RimAlpha.")]
    [Range(0f, 1f)]
    [SerializeField] private float rimAlpha = 0.65f;

    [Header("Detection")]
    [Tooltip("Layer de objetos detectables. Debe incluir Suspect.")]
    [SerializeField] private LayerMask suspectMask;

    [Tooltip("Tiempo que quedan visibles el holograma, outline e item luego de que el pulso toca al sospechoso.")]
    [SerializeField] private float revealDuration = 4f;

    private readonly Collider[] hits = new Collider[64];
    private readonly HashSet<StencilDetectable> detectedThisPulse = new HashSet<StencilDetectable>();
    private MaterialPropertyBlock pulseBlock;
    private Renderer pulseRenderer;
    private float pulseTime;
    private bool pulseActive;

    private static readonly int PulseColor = Shader.PropertyToID("_PulseColor");
    private static readonly int BaseAlpha = Shader.PropertyToID("_BaseAlpha");
    private static readonly int RimAlpha = Shader.PropertyToID("_RimAlpha");
    private static readonly int LegacyPulseAlpha = Shader.PropertyToID("_PulseAlpha");

    private void Reset()
    {
        AutoAssignReferences();
        ApplyScannerShaderValues();
    }

    private void OnValidate()
    {
        maxRadius = Mathf.Max(0.1f, maxRadius);
        expansionSpeed = Mathf.Max(0.01f, expansionSpeed);
        growthScale.x = Mathf.Max(0.01f, growthScale.x);
        growthScale.y = Mathf.Max(0.01f, growthScale.y);
        growthScale.z = Mathf.Max(0.01f, growthScale.z);
        baseAlpha = Mathf.Clamp01(baseAlpha);
        rimAlpha = Mathf.Clamp01(rimAlpha);
        revealDuration = Mathf.Max(0.05f, revealDuration);

        if (pulseSphere == null || suspectMask.value == 0 || pulseRenderer == null)
            AutoAssignReferences();

        ApplyScannerShaderValues();
    }

    private void Awake()
    {
        AutoAssignReferences();
        ApplyScannerShaderValues();

        if (pulseSphere != null)
            pulseSphere.gameObject.SetActive(false);
    }

    private void Update()
    {
        ApplyScannerShaderValues();

        if (Input.GetKeyDown(scanKey))
            StartPulse();

        if (pulseActive)
            UpdatePulse();
    }

    [ContextMenu("Auto Assign References")]
    public void AutoAssignReferences()
    {
        if (pulseSphere == null)
            pulseSphere = FindChildByName(transform, "ScannerSphere");

        if (pulseSphere != null && pulseRenderer == null)
            pulseRenderer = pulseSphere.GetComponent<Renderer>();

        if (suspectMask.value == 0)
        {
            int suspectLayer = LayerMask.NameToLayer("Suspect");

            if (suspectLayer >= 0)
                suspectMask = 1 << suspectLayer;
        }
    }

    private void StartPulse()
    {
        pulseTime = 0f;
        pulseActive = true;
        detectedThisPulse.Clear();

        if (pulseSphere != null)
        {
            pulseSphere.gameObject.SetActive(true);
            pulseSphere.position = transform.position;
            pulseSphere.localScale = Vector3.zero;
            ApplyScannerShaderValues();
        }
    }

    private void UpdatePulse()
    {
        pulseTime += Time.deltaTime;
        float normalizedTime = Mathf.Clamp01(pulseTime * expansionSpeed / maxRadius);
        float radius = radiusCurve.Evaluate(normalizedTime) * maxRadius;

        if (pulseSphere != null)
        {
            float diameter = radius * 2f;
            pulseSphere.position = transform.position;
            pulseSphere.localScale = Vector3.Scale(Vector3.one * diameter, growthScale);
        }

        DetectSuspects(radius);

        if (normalizedTime >= 1f)
        {
            pulseActive = false;

            if (pulseSphere != null)
                pulseSphere.gameObject.SetActive(false);
        }
    }

    private void ApplyScannerShaderValues()
    {
        if (pulseRenderer == null)
            return;

        if (pulseBlock == null)
            pulseBlock = new MaterialPropertyBlock();

        pulseRenderer.GetPropertyBlock(pulseBlock);
        pulseBlock.SetColor(PulseColor, pulseColor);
        pulseBlock.SetFloat(BaseAlpha, baseAlpha);
        pulseBlock.SetFloat(RimAlpha, rimAlpha);
        pulseBlock.SetFloat(LegacyPulseAlpha, baseAlpha);
        pulseRenderer.SetPropertyBlock(pulseBlock);
    }

    private void DetectSuspects(float radius)
    {
        int hitCount = Physics.OverlapSphereNonAlloc(
            transform.position,
            radius,
            hits,
            suspectMask,
            QueryTriggerInteraction.Collide
        );

        for (int i = 0; i < hitCount; i++)
        {
            StencilDetectable detectable = hits[i].GetComponentInParent<StencilDetectable>();

            if (detectable == null || detectedThisPulse.Contains(detectable))
                continue;

            detectedThisPulse.Add(detectable);
            detectable.Reveal(revealDuration);
        }
    }

    private static Transform FindChildByName(Transform root, string childName)
    {
        Transform[] children = root.GetComponentsInChildren<Transform>(true);

        for (int i = 0; i < children.Length; i++)
        {
            if (children[i].name == childName)
                return children[i];
        }

        return null;
    }
}
