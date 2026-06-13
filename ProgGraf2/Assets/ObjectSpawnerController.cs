using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectSpawnerController : MonoBehaviour
{
    [SerializeField] Transform prefabs;
    [SerializeField] Transform container;

    private List<GameObject> objectsList = new List<GameObject>();


    public float AreaToFill= 10.0f;
    public int Density=1000;

    // Start is called before the first frame update
    void Start()
    {
        
        foreach (Transform t in prefabs) {
            objectsList.Add(t.gameObject);
            Debug.Log(t.gameObject.name);
        }
        Debug.Log(objectsList.Count);
        FillScene();
    }

    // Update is called once per frame
    void Update()
    {
        
    }


    public void FillScene()
    {

        for (int i = 0; i < Density; i++)
        {
            int pick = Random.Range(0, objectsList.Count);
            Debug.Log(pick);
            GameObject go = Instantiate(objectsList[pick], container);

            go.transform.position = new Vector3(
                this.transform.position.x + Random.Range(-AreaToFill, AreaToFill),
                this.transform.position.y,
                this.transform.position.z + Random.Range(-AreaToFill, AreaToFill)

                );

            go.SetActive(true);

        }
    }
}
