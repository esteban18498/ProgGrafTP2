using System.Collections;
using System.Collections.Generic;
using System.Xml.Serialization;
using UnityEngine;

public class ObjectSpawnerController : MonoBehaviour
{
    [SerializeField] Transform prefabs;
    [SerializeField] Transform container;
    [SerializeField] GameObject ObjectToFind;
    private List<GameObject> objectsList = new List<GameObject>();


    public float AreaToFill= 10.0f;
    public int Density=1000;

    // Start is called before the first frame update
    void Start()
    {
        
        foreach (Transform t in prefabs) {
            objectsList.Add(t.gameObject);
            //Debug.Log(t.gameObject.name);
        }
        //Debug.Log(objectsList.Count);
        FillScene();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    [ContextMenu("FillScene")]
    public void InEditorFillScene()
    {
        objectsList = new List<GameObject>();
        foreach (Transform t in prefabs)
        {
            objectsList.Add(t.gameObject);
            //Debug.Log(t.gameObject.name);
        }
        //Debug.Log(objectsList.Count);
        FillScene();

    }

    public void FillScene()
    {

        //Clean Container
        if (container.childCount > 0)
        {
            foreach (Transform t in container)
            {
#if UNITY_EDITOR
                // This line only exists when testing inside Unity
                DestroyImmediate(t.gameObject);
                Debug.Log("Running inside the Unity Editor layout.");
#else
                // This line only exists in your final exported game build
                Debug.Log("Running inside the final game build!");
                Destroy(t.gameObject);
#endif
            }
        }


        //Fill With randoms
        for (int i = 0; i < Density; i++)
        {
            int pick = Random.Range(0, objectsList.Count);
            GameObject go = Instantiate(objectsList[pick], container);

            go.transform.position = new Vector3(
                this.transform.position.x + Random.Range(-AreaToFill, AreaToFill),
                this.transform.position.y,
                this.transform.position.z + Random.Range(-AreaToFill, AreaToFill)

                );

            go.SetActive(true);

        }

        //Add Object to find
        GameObject goToFind = Instantiate(ObjectToFind, container);
        goToFind.transform.position = new Vector3(
            this.transform.position.x + Random.Range(-AreaToFill, AreaToFill),
            this.transform.position.y,
            this.transform.position.z + Random.Range(-AreaToFill, AreaToFill)

            );

        goToFind.SetActive(true);

    }
}
