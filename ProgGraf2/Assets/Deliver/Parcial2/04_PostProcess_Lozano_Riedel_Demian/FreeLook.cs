using UnityEngine;

public class FreeLook : MonoBehaviour
{
    public float sensibilidad = 3f;

    float rotacionX = 0f;
    float rotacionY = 0f;

    void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;

        Vector3 angulos = transform.eulerAngles;
        rotacionX = angulos.x;
        rotacionY = angulos.y;
    }

    void Update()
    {
        rotacionY += Input.GetAxis("Mouse X") * sensibilidad;
        rotacionX -= Input.GetAxis("Mouse Y") * sensibilidad;

        rotacionX = Mathf.Clamp(rotacionX, -90f, 90f);

        transform.rotation = Quaternion.Euler(rotacionX, rotacionY, 0f);
    }
}