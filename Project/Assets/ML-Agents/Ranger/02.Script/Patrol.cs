using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorDesigner.Runtime;
using BehaviorDesigner.Runtime.Tasks;

public class Patrol : Action
{
    public float speed = 2f;
    public float directionChangeInterval = 2f;

    private Rigidbody rb;
    private Vector3 moveDirection;
    private float timer;

    public override void OnStart()
    {
        rb = GetComponent<Rigidbody>();
        PickNewDirection();
    }

    public override TaskStatus OnUpdate()
    {
        timer -= Time.deltaTime;

        if (timer <= 0f)
        {
            PickNewDirection();
        }

        rb.MovePosition(transform.position + moveDirection * speed * Time.deltaTime);

        return TaskStatus.Running;
    }

    private void PickNewDirection()
    {
        float angle = Random.Range(0f, 360f);
        moveDirection = new Vector3(Mathf.Cos(angle), 0, Mathf.Sin(angle)).normalized;
        timer = directionChangeInterval;
    }
}
