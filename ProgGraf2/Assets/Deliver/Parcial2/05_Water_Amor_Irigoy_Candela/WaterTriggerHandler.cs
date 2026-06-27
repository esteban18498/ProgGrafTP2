using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterTriggerHandler : MonoBehaviour
{
    [SerializeField] private LayerMask _waterMask;

    private EdgeCollider2D _edgeCollider;

    private InteractableWater _water;

    private void Awake()
    {
        _edgeCollider = GetComponent<EdgeCollider2D>();
        _water = GetComponent<InteractableWater>();
    }

    private void OnTriggerEnter2D(Collider2D collision)
    {
        CircleController circle = collision.GetComponent<CircleController>();
        if (circle)
        {
            float force = circle.velocity.magnitude * circle.velocity.y / Mathf.Abs(circle.velocity.y);
            _water.Splash(collision, force * 65);
        }
    }
}
