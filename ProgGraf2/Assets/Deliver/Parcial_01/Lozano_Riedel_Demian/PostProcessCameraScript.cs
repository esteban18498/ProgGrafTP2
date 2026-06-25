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

    public Color damageColor;

    public Color healColor;

    public Color accentColor = Color.white;

    public Texture myTexture;
    
    private float damageTimeCounter= 0;
    

    public float damageTotalTime;


    public float damageFlashUmbral;

    public float damageColorUmbral;

    private float healTimeCounter = 0;
    public float healTotalTime;

    public float healFlashUmbral;
    public float healColorUmbral;
    
    [SerializeField] public Texture damageTexture;

    [SerializeField] public Texture healingTexture;
    
    

    private bool parpadear = false;

    private bool damage = false;

    private bool heal = false;

    private bool effect = false;

    private bool cancelEffect = false;

    private float hitflashCounter = 0f;
    
    
    

    private readonly int ColorID = Shader.PropertyToID("_ColorMult");

    private readonly int CenterVector = Shader.PropertyToID("_CenterVector");

    private readonly int StepValueVector = Shader.PropertyToID("_StepValueVector");

    private readonly int EffectTexture = Shader.PropertyToID("_EffectTexture");


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
        myTexture = damageTexture;



        if (parpadear)

        {

            myStepValueVector.x = Mathf.Lerp(0.3f, -2f, 0.5f);



        }

        if (effect)
        {
            myStepValueVector.x = Mathf.Lerp(myStepValueVector.x, 0.2f, 1f);
            myStepValueVector.y = Mathf.Lerp(myStepValueVector.x, 0.8f, 1f);

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

        if (Input.GetKey(KeyCode.W))
        {

            Debug.Log("parpadear");

            Parpadear();

        }



        // Modificar Shader



        material.SetColor(ColorID, myColor);

        material.SetVector(CenterVector, myCenterVector);

        material.SetVector(StepValueVector, myStepValueVector);

        material.SetTexture(EffectTexture, myTexture);

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

        parpadear = !parpadear;

    }

    private void Damage()

    {

        damage = true;


    }

    private void Heal()

    {

        heal = true;

    }

}

