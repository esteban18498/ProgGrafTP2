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
        if (binocularImage != null)
        {
            binocularMat = binocularImage.material;
            point = Shader.PropertyToID("_point");
        }

    }

    void Update()
    {
        if (binocularMat == null) return;

        Vector2 mousePos = new Vector2((Input.mousePosition.x / Screen.width) , (Input.mousePosition.y / Screen.height) );

        binocularMat.SetVector(point, mousePos);




        if (Input.GetMouseButtonDown(0))
        {
            
            RaycastHit hit;


        }

    }
}
