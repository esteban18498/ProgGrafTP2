using System.Collections;
using System.Collections.Generic;
using System.Xml.Serialization;
using UnityEngine;


struct ObjectToDraw
{
    public Mesh mesh;
    public Material material;

    public Vector3 position;

    public Quaternion rotation;
}

public class ObjectSpawnerController : MonoBehaviour
{


    public float AreaToFill= 10.0f;
    public int Density=1000;
    public float rotationSpeed = 10.0f;






    public Mesh[] fillerMeshes;
    public Material[] FillerMaterial;
    private List<ObjectToDraw> objectsList;

    public Mesh TargetMesh;
    public Material TargetMaterial;
    private ObjectToDraw targetObject;


    // Start is called before the first frame update
    void Start()
    {
        objectsList = new List<ObjectToDraw>();



        float tx = Random.Range(-AreaToFill, AreaToFill);
        float ty = Random.Range(-0.1f, 0.1f);
        float tz = Random.Range(-AreaToFill, AreaToFill);
        targetObject = new ObjectToDraw()
        {
            mesh = TargetMesh,
            material = TargetMaterial,

            position = new Vector3(tx, ty, tz),
            rotation = Quaternion.identity
        };


        // will make the mesh appear in the Scene at origin position
        for (int i = 0; i < Density; i++)
        {
            float x = Random.Range(-AreaToFill, AreaToFill);
            float y = Random.Range(-0.1f, 0.1f);
            float z = Random.Range(-AreaToFill, AreaToFill);

            Mesh m = Random.Range(0, fillerMeshes.Length) < fillerMeshes.Length ? fillerMeshes[Random.Range(0, fillerMeshes.Length)] : null;
            Material mat = Random.Range(0, FillerMaterial.Length) < FillerMaterial.Length ? FillerMaterial[Random.Range(0, FillerMaterial.Length)] : null;

            ObjectToDraw obj = new ObjectToDraw()
            {
                mesh = m,
                material = mat,
                position = new Vector3(x, y, z),
                rotation = Quaternion.Euler(Random.Range(0, 360), Random.Range(0, 360), Random.Range(0, 360))
            };
            objectsList.Add(obj);
        }



    }


    public void Update()
    {
        for (var i = 0; i < objectsList.Count; i++)
        {
            var item = objectsList[i];
            item.rotation = Quaternion.Euler(0, item.rotation.eulerAngles.y + Time.deltaTime * rotationSpeed, 0);
            objectsList[i] = item;
            Graphics.DrawMesh(item.mesh, item.position, item.rotation, item.material, 0);
        }

        targetObject.rotation = Quaternion.Euler(0, targetObject.rotation.eulerAngles.y + Time.deltaTime * rotationSpeed, 0);
        Graphics.DrawMesh(targetObject.mesh, targetObject.position, targetObject.rotation, targetObject.material, 0);
    }
}
