using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorDesigner.Runtime;
using BehaviorDesigner.Runtime.Tasks;

public class CanSeePlayer : Conditional
{
    public SharedTransform player;  // Behavior Tree에서 연결됨
    public float viewDistance = 10f;
    public float viewAngle = 120f;

    public override TaskStatus OnUpdate()
    {
        if (player.Value == null)
        {
            Debug.LogWarning("player is not set!");
            return TaskStatus.Failure;
        }

        Vector3 direction = player.Value.position - transform.position;
        float distance = direction.magnitude;
        float angle = Vector3.Angle(transform.forward, direction);

        Debug.Log($"Distance: {distance}, Angle: {angle}");

        if (distance > viewDistance) return TaskStatus.Failure;
        if (angle > viewAngle / 2f) return TaskStatus.Failure;

        return TaskStatus.Success;
    }

}

