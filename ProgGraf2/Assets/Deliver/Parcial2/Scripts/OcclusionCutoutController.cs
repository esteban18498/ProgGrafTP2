using UnityEngine;

[ExecuteAlways]
public class OcclusionCutoutController : MonoBehaviour
{
    private const float MinCutoutRadius = 0.0f;
    private const float MaxCutoutRadius = 5f;
    private const float MinCutoutFeather = 0.0f;
    private const float MaxCutoutFeather = 1f;
    private const float MinCutoutEnd = 0f;
    private const float MaxCutoutEnd = 1f;
    private const float MinRingWidth = 0.0f;
    private const float MaxRingWidth = 1f;
    private const float MinRingIntensity = 0f;
    private const float MaxRingIntensity = 5f;
    private const float MinSphereCastRadius = 0.01f;
    private const float MaxSphereCastRadius = 5f;
    private const float MinCheckInterval = 0.02f;
    private const float MaxCheckInterval = 1f;
    private const float MinSmoothSpeed = 0.1f;
    private const float MaxSmoothSpeed = 30f;

    [Header("References")]
    [Tooltip("Camara que define el inicio de la linea de vision hacia el player. Si esta vacia usa Camera.main.")]
    [SerializeField] private Camera targetCamera;
    [Tooltip("Transform del player que debe quedar visible. Define el final de la linea camara-player.")]
    [SerializeField] private Transform player;

    [Header("Occluders")]
    [Tooltip("Renderers que reciben las propiedades del shader. Si Auto Find Occluders esta activo, se completan automaticamente por layer.")]
    [SerializeField] private Renderer[] occluderRenderers;
    [Tooltip("Busca automaticamente todos los renderers en Occluder Mask al iniciar la escena.")]
    [SerializeField] private bool autoFindOccluders = true;
    [Tooltip("Layers que pueden tapar al player y recibir el agujero. Normalmente debe ser la layer Occluder.")]
    [SerializeField] private LayerMask occluderMask;

    [Header("Detection")]
    [Tooltip("Grosor del SphereCast entre camara y player. Aumentalo si la deteccion falla por paredes finas o bordes.")]
    [Range(MinSphereCastRadius, MaxSphereCastRadius)]
    [SerializeField] private float sphereCastRadius = 0.35f;
    [Tooltip("Cada cuantos segundos se recalcula si hay un oclusor entre camara y player. Menor es mas reactivo, mayor es mas barato.")]
    [Range(MinCheckInterval, MaxCheckInterval)]
    [SerializeField] private float checkInterval = 0.1f;

    [Header("Cutout")]
    [Tooltip("Radio del agujero transparente alrededor de la linea camara-player, en unidades de mundo.")]
    [Range(MinCutoutRadius, MaxCutoutRadius)]
    [SerializeField] private float cutoutRadius = 0.8f;
    [Tooltip("Ancho del borde suave del agujero. Valores mas altos hacen un fade mas gradual.")]
    [Range(MinCutoutFeather, MaxCutoutFeather)]
    [SerializeField] private float cutoutFeather = 0.35f;
    [Tooltip("Alpha en el centro del agujero. 0 es totalmente invisible, 1 no abre agujero.")]
    [Range(0f, 1f)]
    [SerializeField] private float holeAlpha = 0f;
    [Tooltip("Hasta que punto de la linea camara-player llega el efecto. 0 es la camara, 1 es el player; 0.85 corta antes del player para no afectar paredes detras.")]
    [Range(MinCutoutEnd, MaxCutoutEnd)]
    [SerializeField] private float cutoutEnd = 0.85f;
    [Tooltip("Color base que se envia al shader de las paredes oclusoras.")]
    [SerializeField] private Color baseColor = new Color(0.3301887f, 0.2414116f, 0.2414116f, 0f);

    [Header("Ring")]
    [Tooltip("Color del halo/emision que marca el borde del agujero.")]
    [SerializeField] private Color ringColor = Color.yellow;
    [Tooltip("Ancho del halo alrededor del borde. Valores chicos dan un borde fino; valores altos lo ensanchan.")]
    [Range(MinRingWidth, MaxRingWidth)]
    [SerializeField] private float ringWidth = 0.08f;
    [Tooltip("Intensidad de la emision del halo. 0 lo apaga, 5 lo vuelve muy brillante.")]
    [Range(MinRingIntensity, MaxRingIntensity)]
    [SerializeField] private float ringIntensity = 1.5f;

    [Header("Smoothing")]
    [Tooltip("Velocidad de suavizado para activar/desactivar el efecto y seguir al player. Mayor es mas inmediato.")]
    [Range(MinSmoothSpeed, MaxSmoothSpeed)]
    [SerializeField] private float smoothSpeed = 12f;

    private MaterialPropertyBlock block;
    private readonly RaycastHit[] hits = new RaycastHit[32];
    private float nextCheckTime;
    private float targetActive;
    private float currentActive;
    private Vector3 smoothedPlayerPosition;

    private static readonly int CutoutCameraWS = Shader.PropertyToID("_CutoutCameraWS");
    private static readonly int CutoutAvatarWS = Shader.PropertyToID("_CutoutAvatarWS");
    private static readonly int CutoutRadius = Shader.PropertyToID("_CutoutRadius");
    private static readonly int CutoutFeather = Shader.PropertyToID("_CutoutFeather");
    private static readonly int CutoutEnd = Shader.PropertyToID("_CutoutEnd");
    private static readonly int CutoutActive = Shader.PropertyToID("_CutoutActive");
    private static readonly int HoleAlpha = Shader.PropertyToID("_HoleAlpha");
    private static readonly int RingColor = Shader.PropertyToID("_RingColor");
    private static readonly int RingWidth = Shader.PropertyToID("_RingWidth");
    private static readonly int RingIntensity = Shader.PropertyToID("_RingIntensity");
    private static readonly int BaseColor = Shader.PropertyToID("_BaseColor");

    private void Awake()
    {
        Initialize();
    }

    private void OnEnable()
    {
        Initialize();
    }

    private void OnValidate()
    {
        ClampSettings();
        Initialize();
        UpdateEffectInEditMode();
    }

    private void Update()
    {
        if (targetCamera == null || player == null)
            return;

        ClampSettings();

        if (!Application.isPlaying)
        {
            UpdateEffectInEditMode();
            return;
        }

        if (Time.time >= nextCheckTime)
        {
            targetActive = IsPlayerOccluded(targetCamera.transform.position, player.position) ? 1f : 0f;
            nextCheckTime = Time.time + checkInterval;
        }

        float smoothing = 1f - Mathf.Exp(-smoothSpeed * Time.deltaTime);
        currentActive = Mathf.Lerp(currentActive, targetActive, smoothing);
        smoothedPlayerPosition = Vector3.Lerp(smoothedPlayerPosition, player.position, smoothing);

        ApplyShaderValues();
    }

    private void Initialize()
    {
        ClampSettings();

        if (targetCamera == null)
            targetCamera = Camera.main;

        if (block == null)
            block = new MaterialPropertyBlock();

        if (player != null && smoothedPlayerPosition == Vector3.zero)
            smoothedPlayerPosition = player.position;

        ResolveDefaultOccluderMask();
        RefreshOccluders();
    }

    private void UpdateEffectInEditMode()
    {
        if (targetCamera == null || player == null)
            return;

        ResolveDefaultOccluderMask();
        RefreshOccluders();

        targetActive = IsPlayerOccluded(targetCamera.transform.position, player.position) ? 1f : 0f;
        currentActive = targetActive;
        smoothedPlayerPosition = player.position;

        ApplyShaderValues();
    }

    private void ApplyShaderValues()
    {
        if (block == null)
            block = new MaterialPropertyBlock();

        if (occluderRenderers == null)
            return;

        Vector3 cameraPosition = targetCamera.transform.position;

        for (int i = 0; i < occluderRenderers.Length; i++)
        {
            Renderer renderer = occluderRenderers[i];

            if (renderer == null)
                continue;

            renderer.GetPropertyBlock(block);

            block.SetVector(CutoutCameraWS, cameraPosition);
            block.SetVector(CutoutAvatarWS, smoothedPlayerPosition);
            block.SetFloat(CutoutRadius, cutoutRadius);
            block.SetFloat(CutoutFeather, cutoutFeather);
            block.SetFloat(CutoutEnd, cutoutEnd);
            block.SetFloat(CutoutActive, Mathf.Clamp01(currentActive));
            block.SetFloat(HoleAlpha, holeAlpha);
            block.SetColor(RingColor, ringColor);
            block.SetFloat(RingWidth, ringWidth);
            block.SetFloat(RingIntensity, ringIntensity);
            block.SetColor(BaseColor, baseColor);

            renderer.SetPropertyBlock(block);
        }
    }

    private bool IsPlayerOccluded(Vector3 cameraPosition, Vector3 playerPosition)
    {
        Vector3 cameraToPlayer = playerPosition - cameraPosition;
        float distance = cameraToPlayer.magnitude;

        if (distance <= 0.01f)
            return false;

        Vector3 direction = cameraToPlayer / distance;

        int hitCount = Physics.SphereCastNonAlloc(
            cameraPosition,
            sphereCastRadius,
            direction,
            hits,
            distance,
            occluderMask,
            QueryTriggerInteraction.Ignore
        );

        return hitCount > 0;
    }

    private void ResolveDefaultOccluderMask()
    {
        if (occluderMask.value != 0)
            return;

        int occluderLayer = LayerMask.NameToLayer("Occluder");

        if (occluderLayer >= 0)
            occluderMask = 1 << occluderLayer;
    }

    private void RefreshOccluders()
    {
        if (!autoFindOccluders || occluderMask.value == 0)
            return;

        Renderer[] sceneRenderers = FindObjectsOfType<Renderer>();
        int occluderCount = 0;

        for (int i = 0; i < sceneRenderers.Length; i++)
        {
            if (IsInOccluderMask(sceneRenderers[i]))
                occluderCount++;
        }

        Renderer[] foundOccluders = new Renderer[occluderCount];
        int writeIndex = 0;

        for (int i = 0; i < sceneRenderers.Length; i++)
        {
            Renderer renderer = sceneRenderers[i];

            if (!IsInOccluderMask(renderer))
                continue;

            foundOccluders[writeIndex] = renderer;
            writeIndex++;
        }

        occluderRenderers = foundOccluders;
    }

    private bool IsInOccluderMask(Renderer renderer)
    {
        if (renderer == null)
            return false;

        int layerMask = 1 << renderer.gameObject.layer;
        return (occluderMask.value & layerMask) != 0;
    }

    private void ClampSettings()
    {
        cutoutRadius = Mathf.Clamp(cutoutRadius, MinCutoutRadius, MaxCutoutRadius);
        cutoutFeather = Mathf.Clamp(cutoutFeather, MinCutoutFeather, MaxCutoutFeather);
        holeAlpha = Mathf.Clamp01(holeAlpha);
        cutoutEnd = Mathf.Clamp(cutoutEnd, MinCutoutEnd, MaxCutoutEnd);
        ringWidth = Mathf.Clamp(ringWidth, MinRingWidth, MaxRingWidth);
        ringIntensity = Mathf.Clamp(ringIntensity, MinRingIntensity, MaxRingIntensity);
        sphereCastRadius = Mathf.Clamp(sphereCastRadius, MinSphereCastRadius, MaxSphereCastRadius);
        checkInterval = Mathf.Clamp(checkInterval, MinCheckInterval, MaxCheckInterval);
        smoothSpeed = Mathf.Clamp(smoothSpeed, MinSmoothSpeed, MaxSmoothSpeed);
    }
}