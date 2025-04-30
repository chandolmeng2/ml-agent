using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraFollow3 : MonoBehaviour
{
    public Transform player;             // 플레이어 Transform
    public float mouseSensitivity = 100f;

    float xRotation = 0f;

    void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;  // 마우스 커서 고정
    }

    void Update()
    {
        float mouseX = Input.GetAxis("Mouse X") * mouseSensitivity * Time.deltaTime;
        float mouseY = Input.GetAxis("Mouse Y") * mouseSensitivity * Time.deltaTime;

        xRotation -= mouseY;
        xRotation = Mathf.Clamp(xRotation, -90f, 90f); // 카메라가 위 아래로 너무 많이 돌아가지 않도록 제한

        transform.localRotation = Quaternion.Euler(xRotation, 0f, 0f);      // 카메라 x축 회전 (상하)
        player.Rotate(Vector3.up * mouseX);                                 // 플레이어 y축 회전 (좌우)
    }
}
