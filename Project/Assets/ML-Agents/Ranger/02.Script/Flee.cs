using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorDesigner.Runtime;
using BehaviorDesigner.Runtime.Tasks;

public class Flee : Action
{
    public SharedTransform player;
    public float fleeSpeed = 3f;

    private Rigidbody rb;

    public override void OnStart()
    {
        rb = GetComponent<Rigidbody>();
    }

    public override TaskStatus OnUpdate()
    {
        if (player.Value == null) return TaskStatus.Failure;

        Vector3 direction = (transform.position - player.Value.position).normalized;
        Vector3 newPos = transform.position + direction * fleeSpeed * Time.deltaTime;

        rb.MovePosition(newPos);

        return TaskStatus.Running;
    }
}
