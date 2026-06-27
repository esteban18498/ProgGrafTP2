using System.Collections.Generic;
using UnityEngine;

[DisallowMultipleComponent]
public class StencilDetectable : MonoBehaviour
{
    [Header("Auto Setup")]
    [Tooltip("Busca automaticamente renderers hijos cuyo nombre/ruta contenga hologram, outline o SuspiciousItem.")]
    [SerializeField] private bool autoFindRenderers = true;

    [Header("Effect Renderers")]
    [Tooltip("Renderers del cuerpo/cabeza con el material lector holografico. Se prenden cuando la esfera detecta este sospechoso.")]
    [SerializeField] private Renderer[] hologramRenderers;

    [Tooltip("Renderers duplicados para el outline. Se prenden junto con el holograma.")]
    [SerializeField] private Renderer[] outlineRenderers;

    [Tooltip("Renderers del objeto interno sospechoso. En el sospechoso sin item puede quedar vacio.")]
    [SerializeField] private Renderer[] itemRenderers;

    private float revealTimer;

    private void Reset()
    {
        RefreshRendererLists();
        SetEffectVisible(false);
    }

    private void OnValidate()
    {
        if (autoFindRenderers)
            RefreshRendererLists();

        if (!Application.isPlaying)
            SetEffectVisible(false);
    }

    private void Awake()
    {
        if (autoFindRenderers)
            RefreshRendererLists();

        SetEffectVisible(false);
    }

    private void Update()
    {
        if (revealTimer <= 0f)
            return;

        revealTimer -= Time.deltaTime;

        if (revealTimer <= 0f)
            SetEffectVisible(false);
    }

    public void Reveal(float duration)
    {
        revealTimer = Mathf.Max(0.05f, duration);
        SetEffectVisible(true);
    }

    [ContextMenu("Refresh Renderer Lists")]
    public void RefreshRendererLists()
    {
        Renderer[] childRenderers = GetComponentsInChildren<Renderer>(true);
        List<Renderer> holograms = new List<Renderer>();
        List<Renderer> outlines = new List<Renderer>();
        List<Renderer> items = new List<Renderer>();

        for (int i = 0; i < childRenderers.Length; i++)
        {
            Renderer candidate = childRenderers[i];
            string path = GetTransformPath(candidate.transform).ToLowerInvariant();

            if (path.Contains("hologram"))
                holograms.Add(candidate);
            else if (path.Contains("outline"))
                outlines.Add(candidate);
            else if (path.Contains("suspiciousitem"))
                items.Add(candidate);
        }

        hologramRenderers = holograms.ToArray();
        outlineRenderers = outlines.ToArray();
        itemRenderers = items.ToArray();
    }

    private void SetEffectVisible(bool visible)
    {
        SetRenderersVisible(hologramRenderers, visible);
        SetRenderersVisible(outlineRenderers, visible);
        SetRenderersVisible(itemRenderers, visible);
    }

    private static void SetRenderersVisible(Renderer[] renderers, bool visible)
    {
        if (renderers == null)
            return;

        for (int i = 0; i < renderers.Length; i++)
        {
            if (renderers[i] != null)
                renderers[i].enabled = visible;
        }
    }

    private static string GetTransformPath(Transform target)
    {
        string path = target.name;
        Transform current = target.parent;

        while (current != null)
        {
            path = current.name + "/" + path;
            current = current.parent;
        }

        return path;
    }
}
