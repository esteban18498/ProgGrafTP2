using UnityEngine;

public class OcclusionCutoutController : MonoBehaviour
{
    [Header("References")]
    [SerializeField] private Camera targetCamera;
    [SerializeField] private Transform player;

    [Header("Occluder Material")]
    [SerializeField] private Renderer[] occluderRenderers;

    [Header("Cutout Settings")]
    [SerializeField] private float cutoutRadius = 0.8f;
    [SerializeField] private float cutoutFeather = 0.35f;
    [Range(0f, 1f)]
    [SerializeField] private float holeAlpha = 0f;

    [Header("Detection")]
    [SerializeField] private LayerMask occluderMask;
    [SerializeField] private float sphereCastRadius = 0.35f;

    private MaterialPropertyBlock block;
    private readonly RaycastHit[] hits = new RaycastHit[16];

    private static readonly int CutoutCameraWS = Shader.PropertyToID("CutoutCameraWS");
    private static readonly int CutoutAvatarWS = Shader.PropertyToID("CutoutAvatarWS");
    private static readonly int CutoutRadius = Shader.PropertyToID("CutoutRadius");
    private static readonly int CutoutFeather = Shader.PropertyToID("CutoutFeather");
    private static readonly int CutoutActive = Shader.PropertyToID("CutoutActive");
    private static readonly int HoleAlpha = Shader.PropertyToID("HoleAlpha");

    private void Awake()
    {
        if (targetCamera == null)
            targetCamera = Camera.main;

        block = new MaterialPropertyBlock();
    }

    private void Update()
    {
        if (targetCamera == null || player == null)
            return;

        Vector3 cameraPosition = targetCamera.transform.position;
        Vector3 playerPosition = player.position;

        float active = IsPlayerOccluded(cameraPosition, playerPosition) ? 1f : 0f;

        for (int i = 0; i < occluderRenderers.Length; i++)
        {
            Renderer renderer = occluderRenderers[i];

            if (renderer == null)
                continue;

            renderer.GetPropertyBlock(block);

            block.SetVector(CutoutCameraWS, cameraPosition);
            block.SetVector(CutoutAvatarWS, playerPosition);
            block.SetFloat(CutoutRadius, cutoutRadius);
            block.SetFloat(CutoutFeather, cutoutFeather);
            block.SetFloat(CutoutActive, active);
            block.SetFloat(HoleAlpha, holeAlpha);

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
}