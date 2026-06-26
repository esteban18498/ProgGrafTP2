using System;
using System.Collections;

using System.Collections.Generic;
using AmplifyShaderEditor;
using UnityEngine;
using UnityEngine.UI;

public class PostProcessCameraScript : MonoBehaviour

{
    [Header("PostProcess")]
    [SerializeField] private Shader shader;

    private Material material;

    public Color myColor;

    public Vector2 myCenterVector;

    public Vector2 myStepValueVector;

    public Color damageColor;

    public Color healColor;

    public Color accentColor = Color.white;

    
    
    private float damageTimeCounter= 0;
   
    

    public float damageTotalTime;


    public float damageFlashUmbral;

    public float damageColorUmbral;

    private float healTimeCounter = 0;
    public float healTotalTime;

    public float healFlashUmbral;
    public float healColorUmbral;
    
    
    
    

    private bool parpadear = false;
    private float parpadeoTimeCounter= 0;
    
    public float parpadeoFlashUmbral;
    public float parpadeoClosedUmbral;
    
    public float parpadeoTotalTime;

    private bool damage = false;

    private bool heal = false;

    private bool effect = false;

    private bool cancelEffect = false;

    private float hitflashCounter = 0f;
    
    
    

    private readonly int ColorID = Shader.PropertyToID("_ColorMult");

    private readonly int CenterVector = Shader.PropertyToID("_CenterVector");

    private readonly int StepValueVector = Shader.PropertyToID("_StepValueVector");

    
    
    [Header("Overlay")]
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


    private void Awake()

    {

        material = new Material(shader);

    }

    private void Start()
    {
        overlayMaterial = new Material(overlayShader);
        
        opaque = new Color(0, 0, 0, 1);
        transparent = new Color(0, 0, 0, 0);
        
        myImage.material = overlayMaterial;
        myImage.material.mainTexture = myTexture;
        myImage.color = transparent;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)

    {

        Graphics.Blit(source, destination, material);

    }

    private void Update()

    {
       



        if (parpadear)

        {
            parpadeoTimeCounter += Time.deltaTime;


                hitflashCounter += Time.deltaTime;

                myColor = Color.black;
                
                

                // Ojo cerrado
                myStepValueVector.x = Mathf.Lerp(myStepValueVector.x, 0f, 0.5f);
                myStepValueVector.y = Mathf.Lerp(myStepValueVector.y, 0f, 0.5f);
                
                Debug.Log(myStepValueVector.x);
                Debug.Log(myStepValueVector.y);

                if (hitflashCounter > parpadeoFlashUmbral && hitflashCounter < parpadeoClosedUmbral)

                {

                   
                // Ojo abierto
                myStepValueVector.x = Mathf.Lerp(0, 0.1f, 1f);
                myStepValueVector.x = Mathf.Lerp(0, 0.5f, 1f);
                
                
                Debug.Log(myStepValueVector.x);
                Debug.Log(myStepValueVector.y);

                }

                if (hitflashCounter > parpadeoClosedUmbral)

                {
                    // Ojo cerrado
                    
                    //myStepValueVector.x = Mathf.Lerp(0.3f, -2f, 0.5f);
                    
                    myStepValueVector.x = Mathf.Lerp(myStepValueVector.x, 0f, 1f);
                    myStepValueVector.y = Mathf.Lerp(myStepValueVector.y, 0f, 1f);

                    Debug.Log(myStepValueVector.x);
                    Debug.Log(myStepValueVector.y);
                

                }

                if (parpadeoTimeCounter > parpadeoTotalTime)
                {
                    
                    // Ojo abierto
                    
                    //myStepValueVector.x = Mathf.Lerp(0.3f, -2f, 0.5f);
                    
                    myStepValueVector.x = Mathf.Lerp(0, 0.1f, 1f);
                    myStepValueVector.x = Mathf.Lerp(0, 0.5f, 1f);
                    
                    Debug.Log(myStepValueVector.x);
                    Debug.Log(myStepValueVector.y);
                    
                    hitflashCounter = 0;
                    parpadeoTimeCounter = 0;
                    CancelEffect();
                    myImage.color = transparent;
                    parpadear = false;

                }

            
            



        }

        if (effect)
        {
            myStepValueVector.x = Mathf.Lerp(myStepValueVector.x, 0.2f, 1f);
            myStepValueVector.y = Mathf.Lerp(myStepValueVector.y, 0.8f, 1f);

            if (myStepValueVector.x == 0.2f)
            {
                Debug.Log("effect false");
                effect = false;
            }

        }

        if (cancelEffect)
        {

            myStepValueVector.x = Mathf.Lerp(myStepValueVector.x, 1f, 1f);
            myStepValueVector.y = Mathf.Lerp(myStepValueVector.y, 1f, 1f);

            if (myStepValueVector.x == 1f && myStepValueVector.y == 1f)
            {
                Debug.Log("canceleffect false");
                cancelEffect = false;
            }

        }

        //DAMAGE EFFECT

        if (damage)

        {
            damageTimeCounter += Time.deltaTime;


            hitflashCounter += Time.deltaTime;

            myColor = damageColor;


            if (hitflashCounter > damageFlashUmbral && hitflashCounter < damageColorUmbral)

            {

                myColor = accentColor;

                Debug.Log("flash blanco");
                Debug.Log(hitflashCounter);

            }

            if (hitflashCounter > damageColorUmbral)

            {
                Debug.Log("rojo de nuevo");
                myColor = damageColor;

                
                

            }

            if (damageTimeCounter > damageTotalTime)
            {
                hitflashCounter = 0;
                damageTimeCounter = 0;
                CancelEffect();
                myImage.color = transparent;
                damage = !damage;

            }

        }


        // Heal Effect

        if (heal)

        {
            healTimeCounter += Time.deltaTime;


            hitflashCounter += Time.deltaTime;

            myColor = healColor;


            if (hitflashCounter > healFlashUmbral && hitflashCounter < healColorUmbral)

            {

                myColor = accentColor;

                //Debug.Log("flash blanco");
                //Debug.Log(hitflashCounter);

            }

            if (hitflashCounter > healColorUmbral)

            {
                //Debug.Log("rojo de nuevo");
                myColor = healColor;




            }

            if (healTimeCounter > healTotalTime)
            {
                hitflashCounter = 0;
                healTimeCounter = 0;
                CancelEffect();
                myImage.color = transparent;
                heal = !heal;

            }

        }


        //Da�ado

        if (Input.GetKey(KeyCode.D))

        {
            Effect();
            Debug.Log("da�o");

            Damage();

            //material.SetColor(ColorID, damageColor);

        }

        //Curacion

        if (Input.GetKey(KeyCode.H))

        {
            Effect();
            Debug.Log("cura");

            Heal();

            //material.SetColor(ColorID, healColor);

        }


        //Parpadeo

        if (Input.GetKey(KeyCode.P))
        {

            Debug.Log("parpadear");

            Parpadear();

        }
        
        if (Input.GetKey(KeyCode.C))

        {
            //Effect();
            Debug.Log("camara");
            
            Camera();

            //material.SetColor(ColorID, healColor);

        }



        // Modificar Shader



        material.SetColor(ColorID, myColor);

        material.SetVector(CenterVector, myCenterVector);

        material.SetVector(StepValueVector, myStepValueVector);
        
        
        overlayMaterial.SetTexture(EffectTexture, myTexture);
        overlayMaterial.SetVector(PanningDirection, myPanningDirection);
        overlayMaterial.SetFloat(PanningSpeed, myPanningSpeed);

        

    }


    private void Effect()
    {
        
        effect = true;
    }

    private void CancelEffect()
    {
        
        cancelEffect = true;



    }

    private void Parpadear()

    {

        parpadear = true;

    }

    private void Damage()

    {
        myTexture = damageTexture;
        myPanningDirection = Vector2.zero;
        myPanningSpeed = 0.0f;
        myImage.color = opaque;
        damage = true;


    }

    private void Heal()

    {
        myTexture = healingTexture;
        myPanningDirection = new Vector2(0f, -1f);
        myPanningSpeed = 0.5f;
        myImage.color = opaque;
        heal = true;

    }
    
    private void Camera()
    {
        myTexture = cameraTexture;
        myPanningDirection = Vector2.zero;
        myPanningSpeed = 0.0f;
        myImage.color = opaque;
    }

}

