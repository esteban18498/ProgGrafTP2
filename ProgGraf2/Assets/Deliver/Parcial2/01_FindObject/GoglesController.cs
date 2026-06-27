using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using static UnityEngine.UI.Image;

public class GoglesController : MonoBehaviour
{
    [Header("Gogles")]
    [SerializeField] private Image binocularImage;
    private Material binocularMat;
    private int point;

    [Header("SnapShot")]
    [SerializeField] private Camera cam;
    [SerializeField] private RenderTexture snapTexture;




    [SerializeField] ObjectSpawnerController spawner;

    void Start()
    {
        if (binocularImage != null)
        {
            binocularMat = binocularImage.material;
            point = Shader.PropertyToID("_point");
            cam.enabled = false;
        }

    }


    void Update()
    {
        if (binocularMat == null) return;

        Vector2 mousePos = new Vector2((Input.mousePosition.x / Screen.width) , (Input.mousePosition.y / Screen.height) );

        binocularMat.SetVector(point, mousePos);



        var maxDistance = 1000;

        if (Input.GetMouseButtonDown(0))
        {

            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;

            // Debug visualization in the Scene view
            Debug.DrawRay(ray.origin, ray.direction * maxDistance, Color.red);

            // Perform the raycast
            if (Physics.Raycast(ray, out hit, maxDistance))
            {
                if (hit.transform.name == "ObjectSpawner")
                    //true)
                {
                    Debug.Log("SnapShot");
                    cam.Render();
                    spawner.Regenerate();
                }

                // Example: Interact with a component
                // if (hit.transform.TryGetComponent(out Enemy enemy)) { enemy.TakeDamage(); }
            }
        }



    }
}
