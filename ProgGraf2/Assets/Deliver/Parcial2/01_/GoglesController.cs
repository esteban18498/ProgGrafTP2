using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GoglesController : MonoBehaviour
{
    [Header("Setup")]
    [SerializeField] private Image binocularImage;
    private Material binocularMat;
    private int point;


    void Start()
    {
        // Get the material from the UI Image
        if (binocularImage != null)
        {
            binocularMat = binocularImage.material;
        }

        // Cache property IDs for optimal performance (prevents string lookups every frame)
        point = Shader.PropertyToID("_point");

    }

    void Update()
    {
        if (binocularMat == null) return;

        // 1. Get mouse screen position normalized between (0,0) and (1,1)
        Vector2 mousePos = new Vector2((Input.mousePosition.x / Screen.width) , (Input.mousePosition.y / Screen.height) );



        // 3. Update the shader properties via script
        binocularMat.SetVector(point, mousePos);
    }
}
