using UnityEngine;
using Unity.MLAgents;
using Unity.MLAgents.Actuators;
using Unity.MLAgents.Sensors;
using System.Collections.Generic;

public class TrainingAgent_Racoon : Agent
{
    public Transform player;  // 추격자 (자동)
    public float playerSpeed = 5f;
    public float agentSpeed = 3f;
    public Transform plane;

    private float areaLimitX;
    private float areaLimitZ;

    private Rigidbody playerRb;
    private Rigidbody agentRb;

    private Animator animator;

    public override void Initialize()
    {
        playerRb = player != null ? player.GetComponent<Rigidbody>() : null;
        agentRb = GetComponent<Rigidbody>();
        animator = GetComponent<Animator>();

        if (animator == null)
            Debug.LogError("Animator component is missing from the Racoon agent.");

        if (player == null)
            Debug.LogError("Player object is not assigned.");

        UpdateAreaLimits();
    }

    public override void OnEpisodeBegin()
    {
        player.position = GetFarRandomPosition(plane.position, 0.0f);
        transform.position = GetFarRandomPosition(player.position, 2.0f);

        agentRb.velocity = Vector3.zero;
        agentRb.angularVelocity = Vector3.zero;

        if (animator == null)
            animator = GetComponent<Animator>();
    }

    private void UpdateAreaLimits()
    {
        areaLimitX = (plane.localScale.x * 10f) / 2f - 0.5f;
        areaLimitZ = (plane.localScale.z * 10f) / 2f - 0.5f;
    }

    private Vector3 GetFarRandomPosition(Vector3 avoidPos, float minDist)
    {
        Vector3 pos;
        int tryLimit = 20;
        do
        {
            float randX = Random.Range(-areaLimitX, areaLimitX);
            float randZ = Random.Range(-areaLimitZ, areaLimitZ);
            pos = new Vector3(randX, 0f, randZ) + plane.position;
            tryLimit--;
        } while (Vector3.Distance(pos, avoidPos) < minDist && tryLimit > 0);

        return pos;
    }

    private Vector3 ClampToPlane(Vector3 pos)
    {
        float x = Mathf.Clamp(pos.x, plane.position.x - areaLimitX, plane.position.x + areaLimitX);
        float z = Mathf.Clamp(pos.z, plane.position.z - areaLimitZ, plane.position.z + areaLimitZ);
        return new Vector3(x, pos.y, z);
    }

    public override void CollectObservations(VectorSensor sensor)
    {
        sensor.AddObservation(transform.position);   // 라쿤 위치 (3)
        sensor.AddObservation(player.position);      // 플레이어 위치 (3)
        sensor.AddObservation(agentRb.velocity);     // 라쿤의 속도 (3)

    }

    public override void OnActionReceived(ActionBuffers actions)
    {
        Vector3 move = new Vector3(actions.ContinuousActions[0], 0, actions.ContinuousActions[1]);

        Vector3 agentNextPos = transform.position + move.normalized * agentSpeed * Time.deltaTime;
        agentNextPos = ClampToPlane(agentNextPos);

        agentRb.MovePosition(agentNextPos);

        if (move != Vector3.zero)
        {
            Quaternion toRotation = Quaternion.LookRotation(move, Vector3.up);
            transform.rotation = Quaternion.Slerp(transform.rotation, toRotation, 0.2f);
        }

        // 애니메이션 설정
        if (animator != null && animator.gameObject.activeInHierarchy)
        {
            float distanceToPlayer = Vector3.Distance(transform.position, player.position);
            animator.SetBool("isRunning", distanceToPlayer < 5f);
        }

        float dist = Vector3.Distance(transform.position, player.position);
        if (dist < 1.0f)
        {
            SetReward(-1.0f);
            EndEpisode();
        }
        else if (StepCount > 3000)
        {
            SetReward(1.0f);
            EndEpisode();
        }
        else
        {
            AddReward(0.01f);
            AddReward(0.001f * dist);
        }
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Player") && player != null)
        {
            SetReward(-1.0f);
            EndEpisode();
        }
    }
}
