    using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcessCameraScript : MonoBehaviour
{
    [SerializeField] private Shader shader;
    private Material material;
    
    public Color myColor;
    public Vector2 myCenterVector;
    public Vector2 myStepValueVector;

    
    private bool parpadear = false;



    private readonly int ColorID = Shader.PropertyToID("_ColorMult");
    private readonly int CenterVector = Shader.PropertyToID("_CenterVector");
    private readonly int StepValueVector = Shader.PropertyToID("_StepValueVector");
    

    private void Awake()
    {
        material = new Material(shader);
      
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, material);
    }

    private void Update()
    {
        if (parpadear)
        {
            myStepValueVector.x = Mathf.Lerp(0.3f, -2f, 0.5f);

            
        }


        material.SetColor(ColorID, myColor);
        material.SetVector(CenterVector, myCenterVector);
        material.SetVector(StepValueVector, myStepValueVector);
        
        if (Input.GetKey(KeyCode.W)){
            Debug.Log("parpadear");
            Parpadear();
        }
    }

    private void Parpadear()
    {
        parpadear = !parpadear;
    }
}
