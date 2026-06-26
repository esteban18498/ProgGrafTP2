using UnityEngine;

public class Iteminspection : MonoBehaviour
{
    [Header("Rotation Settings")]
    [SerializeField] private float rotationSpeed = 5f;
    [SerializeField] private bool invertX = false;
    [SerializeField] private bool invertY = false;

    private bool isRotating;

    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            isRotating = true;
        }

        if (Input.GetMouseButtonUp(0))
        {
            isRotating = false;
        }

        if (isRotating)
        {
            float mouseX = Input.GetAxis("Mouse X");
            float mouseY = Input.GetAxis("Mouse Y");

            if (invertX) mouseX *= -1;
            if (invertY) mouseY *= -1;

            // Rotación horizontal (Y global)
            transform.Rotate(Vector3.up, -mouseX * rotationSpeed, Space.World);

            // Rotación vertical (X local)
            transform.Rotate(Vector3.right, mouseY * rotationSpeed, Space.Self);
        }
    }
}