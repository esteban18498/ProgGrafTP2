using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraMovementEj1 : MonoBehaviour
{
 
     [SerializeField] private float moveSpeed = 10f;
 
     void Update()
     {
         float horizontal = Input.GetAxisRaw("Horizontal"); // A / D
         float vertical = Input.GetAxisRaw("Vertical");     // W / S
 
         Vector3 movement = new Vector3(horizontal, 0f, vertical).normalized;
 
         transform.position += movement * moveSpeed * Time.deltaTime;
     }
 }
