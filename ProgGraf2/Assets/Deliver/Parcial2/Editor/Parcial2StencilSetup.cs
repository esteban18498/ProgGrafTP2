#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

public static class Parcial2StencilSetup
{
    private const string PlayerPrefabPath = "Assets/Deliver/Parcial2/Prefab/Player_01.prefab";
    private const string SuspectPrefabPath = "Assets/Deliver/Parcial2/Prefab/Suspect_01.prefab";
    private const string SuspectItemPrefabPath = "Assets/Deliver/Parcial2/Prefab/Suspect_01_Item.prefab";

    private const string ScannerMaterialPath = "Assets/Deliver/Parcial2/07_Stencil/Shader/M_StencilScanner_Writer.mat";
    private const string HologramMaterialPath = "Assets/Deliver/Parcial2/07_Stencil/Shader/M_Suspect_Hologram_Reader.mat";
    private const string OutlineMaterialPath = "Assets/Deliver/Parcial2/07_Stencil/Shader/M_Suspect_Outline_Reader.mat";
    private const string ItemMaterialPath = "Assets/Deliver/Parcial2/07_Stencil/Shader/M_SuspiciousItem_Reader.mat";

    [MenuItem("Tools/Parcial2/Setup Exercise 7 Stencil")]
    public static void Configure()
    {
        ConfigurePlayerPrefab();
        ConfigureDetectablePrefab(SuspectPrefabPath);
        ConfigureDetectablePrefab(SuspectItemPrefabPath);

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
        Debug.Log("Exercise 7 stencil setup completed.");
    }

    private static void ConfigurePlayerPrefab()
    {
        GameObject root = PrefabUtility.LoadPrefabContents(PlayerPrefabPath);

        try
        {
            StencilPulseScanner scanner = root.GetComponent<StencilPulseScanner>();

            if (scanner == null)
                scanner = root.AddComponent<StencilPulseScanner>();

            Transform scannerSphere = FindChildByName(root.transform, "ScannerSphere");
            Material scannerMaterial = AssetDatabase.LoadAssetAtPath<Material>(ScannerMaterialPath);

            if (scannerSphere != null)
            {
                Renderer sphereRenderer = scannerSphere.GetComponent<Renderer>();

                if (sphereRenderer != null)
                {
                    sphereRenderer.sharedMaterial = scannerMaterial;
                    sphereRenderer.shadowCastingMode = ShadowCastingMode.Off;
                    sphereRenderer.receiveShadows = false;
                    sphereRenderer.enabled = true;
                }

                scannerSphere.localScale = Vector3.zero;
                scannerSphere.gameObject.SetActive(false);
            }

            SerializedObject serializedScanner = new SerializedObject(scanner);
            serializedScanner.FindProperty("scanKey").intValue = (int)KeyCode.R;
            serializedScanner.FindProperty("pulseSphere").objectReferenceValue = scannerSphere;
            serializedScanner.FindProperty("maxRadius").floatValue = 12f;
            serializedScanner.FindProperty("duration").floatValue = 1.2f;
            serializedScanner.FindProperty("revealDuration").floatValue = 4f;
            SetLayerMask(serializedScanner.FindProperty("suspectMask"), "Suspect");
            serializedScanner.ApplyModifiedPropertiesWithoutUndo();

            EditorUtility.SetDirty(scanner);
            PrefabUtility.SaveAsPrefabAsset(root, PlayerPrefabPath);
        }
        finally
        {
            PrefabUtility.UnloadPrefabContents(root);
        }
    }

    private static void ConfigureDetectablePrefab(string prefabPath)
    {
        GameObject root = PrefabUtility.LoadPrefabContents(prefabPath);

        try
        {
            int suspectLayer = LayerMask.NameToLayer("Suspect");

            if (suspectLayer >= 0)
                SetLayerRecursively(root, suspectLayer);

            StencilDetectable detectable = root.GetComponent<StencilDetectable>();

            if (detectable == null)
                detectable = root.AddComponent<StencilDetectable>();

            Material hologramMaterial = AssetDatabase.LoadAssetAtPath<Material>(HologramMaterialPath);
            Material outlineMaterial = AssetDatabase.LoadAssetAtPath<Material>(OutlineMaterialPath);
            Material itemMaterial = AssetDatabase.LoadAssetAtPath<Material>(ItemMaterialPath);

            Renderer[] renderers = root.GetComponentsInChildren<Renderer>(true);

            for (int i = 0; i < renderers.Length; i++)
            {
                Renderer renderer = renderers[i];
                string path = GetTransformPath(renderer.transform).ToLowerInvariant();

                if (path.Contains("hologram"))
                {
                    renderer.sharedMaterial = hologramMaterial;
                    renderer.enabled = false;
                    renderer.shadowCastingMode = ShadowCastingMode.Off;
                    renderer.receiveShadows = false;
                }
                else if (path.Contains("outline"))
                {
                    renderer.sharedMaterial = outlineMaterial;
                    renderer.enabled = false;
                    renderer.shadowCastingMode = ShadowCastingMode.Off;
                    renderer.receiveShadows = false;
                }
                else if (path.Contains("suspiciousitem"))
                {
                    renderer.sharedMaterial = itemMaterial;
                    renderer.enabled = false;
                    renderer.shadowCastingMode = ShadowCastingMode.Off;
                    renderer.receiveShadows = false;
                }
            }

            SerializedObject serializedDetectable = new SerializedObject(detectable);
            serializedDetectable.FindProperty("autoFindRenderers").boolValue = true;
            serializedDetectable.ApplyModifiedPropertiesWithoutUndo();

            detectable.RefreshRendererLists();
            EditorUtility.SetDirty(detectable);
            PrefabUtility.SaveAsPrefabAsset(root, prefabPath);
        }
        finally
        {
            PrefabUtility.UnloadPrefabContents(root);
        }
    }

    private static void SetLayerMask(SerializedProperty layerMaskProperty, string layerName)
    {
        int layer = LayerMask.NameToLayer(layerName);

        if (layer < 0)
            return;

        SerializedProperty bits = layerMaskProperty.FindPropertyRelative("m_Bits");
        bits.intValue = 1 << layer;
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

    private static void SetLayerRecursively(GameObject target, int layer)
    {
        target.layer = layer;

        for (int i = 0; i < target.transform.childCount; i++)
            SetLayerRecursively(target.transform.GetChild(i).gameObject, layer);
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
#endif
