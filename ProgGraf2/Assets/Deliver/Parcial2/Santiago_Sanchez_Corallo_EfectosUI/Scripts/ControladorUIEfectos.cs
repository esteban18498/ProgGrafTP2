using UnityEngine;
using UnityEngine.UI;

public class ControladorUIEfectos : MonoBehaviour
{
    public Slider progressBar;

    public float minimumValue = 0f;
    public float maximumValue = 100f;
    public float multiplier = 10f;

    private void Start()
    {
        progressBar.minValue = minimumValue;
        progressBar.maxValue = maximumValue;
        progressBar.value = 0f;
    }

    private void Update()
    {
        if (Input.GetKey(KeyCode.RightArrow))
        {
            progressBar.value += Time.deltaTime * multiplier;
        }

        if (Input.GetKey(KeyCode.LeftArrow))
        {
            progressBar.value -= Time.deltaTime * multiplier;
        }

        if (Input.GetKeyDown(KeyCode.RightArrow))
        {
            progressBar.value += 1;
        }

        if (Input.GetKeyDown(KeyCode.LeftArrow))
        {
            progressBar.value -= 1;
        }
    }
}