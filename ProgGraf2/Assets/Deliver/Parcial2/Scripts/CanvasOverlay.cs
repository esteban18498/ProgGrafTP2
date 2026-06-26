using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CanvasOverlay : MonoBehaviour
{
    private Material overlayMaterial;
    
    [SerializeField] private Shader overlayShader;
    
    [SerializeField] public  Image myImage;
    
    
    
    [SerializeField] public Texture damageTexture;

    [SerializeField] public Texture healingTexture;
    
    [SerializeField] public Texture cameraTexture;

    private Color opaque;
    private Color transparent;
    
    
    
    public Texture myTexture;
    public Vector2 myPanningDirection;
    public float myPanningSpeed;
    
    
    
    
    private readonly int EffectTexture = Shader.PropertyToID("_EffectTexture");
    private readonly int PanningDirection = Shader.PropertyToID("_PanningDirection");
    private readonly int PanningSpeed = Shader.PropertyToID("_PanningSpeed");
    
    
    void Start()
    {
        

        overlayMaterial = new Material(overlayShader);
        
        opaque = new Color(0, 0, 0, 1);
        transparent = new Color(0, 0, 0, 0);
        
        myImage.material = overlayMaterial;
        myImage.material.mainTexture = myTexture;
        myImage.color = transparent;


    }

    void Update()
    {
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        /////////////////////////////////// INPUTS
        
        
        
        //Da�ado

        if (Input.GetKey(KeyCode.D))

        {
            //Effect();
            Debug.Log("da�o");

            Damage();

            //material.SetColor(ColorID, damageColor);

        }

        //Curacion

        if (Input.GetKey(KeyCode.H))

        {
            //Effect();
            Debug.Log("cura");

            Heal();

            //material.SetColor(ColorID, healColor);

        }
        
        if (Input.GetKey(KeyCode.C))

        {
            //Effect();
            Debug.Log("camara");
            
            Camera();

            //material.SetColor(ColorID, healColor);

        }
        
        
        
        
        
        
        
        
        ///////////////// MATERIALES
        
        overlayMaterial.SetTexture(EffectTexture, myTexture);
        overlayMaterial.SetVector(PanningDirection, myPanningDirection);
        overlayMaterial.SetFloat(PanningSpeed, myPanningSpeed);
        
    }


    private void Damage()
    {
        myTexture = damageTexture;
        myPanningDirection = Vector2.zero;
        myPanningSpeed = 0.0f;
    }

    private void Heal()
    {
        myTexture = healingTexture;
        myPanningDirection = new Vector2(0f, -1f);
        myPanningSpeed = 0.5f;
        myImage.color = opaque;
        
    }
    
    private void Camera()
    {
        myTexture = cameraTexture;
        myPanningDirection = Vector2.zero;
        myPanningSpeed = 0.0f;
        myImage.color = opaque;
    }
    
}
