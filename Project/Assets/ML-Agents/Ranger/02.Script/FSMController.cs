using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FSMController : MonoBehaviour
{
    public enum SquirrelState { Idle, Patrol, Escape }
    private SquirrelState currentState;

    public Transform player;
    public float playerSpeed = 5f;
    public float squirrelSpeed = 3f;
    public Transform plane;

    public GameObject obstaclePrefab;
    public int maxObstacles = 6;

    private float areaLimitX, areaLimitZ;
    private float timer;
    private Vector3 patrolDir;
    private Rigidbody rb;
    private Rigidbody playerRb;

    private List<GameObject> spawnedObstacles = new List<GameObject>();

    void Start()
    {
        rb = GetComponent<Rigidbody>();
        playerRb = player.GetComponent<Rigidbody>();
        UpdateAreaLimits();
        ResetEpisode();
    }

    void Update()
    {
        switch (currentState)
        {
            case SquirrelState.Idle:
                timer += Time.deltaTime;
                if (timer > 1.0f)
                {
                    patrolDir = GetRandomDirection();
                    ChangeState(SquirrelState.Patrol);
                }
                break;

            case SquirrelState.Patrol:
                Move(patrolDir, squirrelSpeed);
                if (Vector3.Distance(transform.position, player.position) < 3.0f)
                {
                    ChangeState(SquirrelState.Escape);
                }
                break;

            case SquirrelState.Escape:
                Vector3 escapeDir = (transform.position - player.position).normalized;
                Move(escapeDir, squirrelSpeed);
                break;
        }

        // 플레이어는 항상 다람쥐를 추격
        Vector3 dirToSquirrel = (transform.position - player.position).normalized;
        Vector3 nextPlayerPos = ClampToPlane(player.position + dirToSquirrel * playerSpeed * Time.deltaTime);
        playerRb.MovePosition(nextPlayerPos);

        // 잡혔는지 확인
        float dist = Vector3.Distance(transform.position, player.position);
        if (dist < 1.0f)
        {
            Debug.Log("FSM: 잡힘");
            ResetEpisode();
        }
    }

    void ChangeState(SquirrelState newState)
    {
        currentState = newState;
        timer = 0f;
    }

    void Move(Vector3 direction, float speed)
    {
        Vector3 nextPos = ClampToPlane(transform.position + direction * speed * Time.deltaTime);
        rb.MovePosition(nextPos);

        if (direction != Vector3.zero)
        {
            Quaternion rot = Quaternion.LookRotation(direction, Vector3.up);
            transform.rotation = Quaternion.Slerp(transform.rotation, rot, 0.2f);
        }
    }

    Vector3 ClampToPlane(Vector3 pos)
    {
        float x = Mathf.Clamp(pos.x, plane.position.x - areaLimitX, plane.position.x + areaLimitX);
        float z = Mathf.Clamp(pos.z, plane.position.z - areaLimitZ, plane.position.z + areaLimitZ);
        return new Vector3(x, pos.y, z);
    }

    Vector3 GetFarRandomPosition(Vector3 avoidPos, float minDist)
    {
        Vector3 pos;
        int tryLimit = 20;
        do
        {
            float x = Random.Range(-areaLimitX, areaLimitX);
            float z = Random.Range(-areaLimitZ, areaLimitZ);
            pos = new Vector3(x, 0.5f, z) + plane.position;
            tryLimit--;
        } while (Vector3.Distance(pos, avoidPos) < minDist && tryLimit > 0);
        return pos;
    }

    void UpdateAreaLimits()
    {
        areaLimitX = (plane.localScale.x * 10f) / 2f - 0.5f;
        areaLimitZ = (plane.localScale.z * 10f) / 2f - 0.5f;
    }

    void ResetEpisode()
    {
        // 위치 초기화
        player.position = GetFarRandomPosition(plane.position, 0.0f);
        transform.position = GetFarRandomPosition(player.position, 2.0f);
        ChangeState(SquirrelState.Idle);

        // 장애물 리셋
        foreach (var obs in spawnedObstacles)
        {
            if (obs != null) Destroy(obs);
        }
        spawnedObstacles.Clear();

        int count = Random.Range(1, maxObstacles + 1);
        for (int i = 0; i < count; i++)
        {
            Vector3 pos = GetFarRandomPosition(transform.position, 1.5f);
            if (Vector3.Distance(pos, player.position) < 1.5f) continue;

            GameObject obs = Instantiate(obstaclePrefab, pos + Vector3.up * 0.5f, Quaternion.identity, transform.parent);
            obs.tag = "Obstacle";
            spawnedObstacles.Add(obs);
        }
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Obstacle"))
        {
            Debug.Log("FSM: 장애물 충돌");
            ResetEpisode();
        }
    }

    Vector3 GetRandomDirection()
    {
        float x = Random.Range(-1f, 1f);
        float z = Random.Range(-1f, 1f);
        return new Vector3(x, 0, z).normalized;
    }
}
