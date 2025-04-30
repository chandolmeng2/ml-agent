using UnityEngine;
using Unity.MLAgents;
using Unity.MLAgents.Actuators;
using Unity.MLAgents.Sensors;
using Random = UnityEngine.Random;
using System.Collections.Generic;

public class TrainingAgent_Racoon : Agent
{
    public Transform player;  // 추격자 (자동)
    public float playerSpeed = 5f;
    public float agentSpeed = 3f;
    public Transform plane;

    public GameObject[] obstaclePrefabs; // 장애물 프리팹
    public int maxObstacles = 6;      // 최대 장애물 개수

    private float areaLimitX;
    private float areaLimitZ;
    private List<GameObject> spawnedObstacles = new List<GameObject>();

    private Rigidbody playerRb;
    private Rigidbody agentRb;

    private Animator animator;

    void Start()
    {
        animator = GetComponent<Animator>();
    }

    public override void Initialize()
    {
        playerRb = player.GetComponent<Rigidbody>();
        agentRb = GetComponent<Rigidbody>();
        animator = GetComponent<Animator>(); // 추가
        UpdateAreaLimits();
    }

    public override void OnEpisodeBegin()
    {
        player.position = GetFarRandomPosition(plane.position, 0.0f); // 기준은 그냥 plane 안이면 OK
        transform.position = GetFarRandomPosition(player.position, 2.0f); // 다람쥐는 플레이어와 일정 거리 이상 떨어지게 배치

        ClearObstacles(); // 이전 장애물 제거
        SpawnRandomObstacles(); // 새 장애물 생성
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

    private void SpawnRandomObstacles()
    {
        int obstacleCount = Random.Range(1, maxObstacles + 1);

        for (int i = 0; i < obstacleCount; i++)
        {
            Vector3 pos = GetFarRandomPosition(transform.position, 1.5f); // 다람쥐 및 플레이어 근처 제외
            if (Vector3.Distance(pos, player.position) < 1.5f) continue;

            // 랜덤으로 하나의 프리팹 선택
            GameObject prefabToSpawn = obstaclePrefabs[Random.Range(0, obstaclePrefabs.Length)];

            GameObject obs = Instantiate(prefabToSpawn, pos + Vector3.up * 0f, Quaternion.identity, transform.parent);
            obs.tag = "Obstacle"; // 태그 꼭 설정되어 있어야 충돌 체크됨
            spawnedObstacles.Add(obs);
        }
    }

    private Vector3 ClampToPlane(Vector3 pos)
    {
        float x = Mathf.Clamp(pos.x, plane.position.x - areaLimitX, plane.position.x + areaLimitX);
        float z = Mathf.Clamp(pos.z, plane.position.z - areaLimitZ, plane.position.z + areaLimitZ);
        return new Vector3(x, pos.y, z);
    }


    private void ClearObstacles()
    {
        foreach (var obs in spawnedObstacles)
        {
            if (obs != null) Destroy(obs);
        }
        spawnedObstacles.Clear();
    }   
    
    public override void CollectObservations(VectorSensor sensor)
    {
        // 기본 위치 정보 외에 RaySensor에서 자동으로 추가 관측됨
        sensor.AddObservation(transform.position);
        sensor.AddObservation(player.position);
    }

    public override void OnActionReceived(ActionBuffers actions)
    {
        // 아기 다람쥐 이동
        Vector3 move = new Vector3(actions.ContinuousActions[0], 0, actions.ContinuousActions[1]);
        Vector3 agentNextPos = transform.position + move.normalized * agentSpeed * Time.deltaTime;
        agentNextPos = ClampToPlane(agentNextPos);
        agentRb.MovePosition(agentNextPos);

        // 이동 방향으로 회전
        if (move != Vector3.zero)
        {
            Quaternion toRotation = Quaternion.LookRotation(move, Vector3.up);
            transform.rotation = Quaternion.Slerp(transform.rotation, toRotation, 0.2f); // 부드럽게 회전
        }

        // 애니메이션
        if (animator != null)
        {
            float distanceToPlayer = Vector3.Distance(transform.position, player.position);
            
            if (distanceToPlayer < 5f)
                animator.SetBool("isRunning", true);
            else
                animator.SetBool("isRunning", false);

        }

        /* 자동 플레이어 추격(학습할 때에만 적용, 게임에는 주석 처리)
        Vector3 dirToAgent = (transform.position - player.position).normalized;
        Vector3 playerNextPos = player.position + dirToAgent * playerSpeed * Time.deltaTime;
        playerNextPos = ClampToPlane(playerNextPos);
        playerRb.MovePosition(playerNextPos);
        */

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
            AddReward(0.01f); // 살아있으면 계속 보상
            AddReward(0.001f * dist); // 멀리 도망갈수록 추가 보상
        }
    }

    private void OnCollisionEnter(Collision collision) // 장애물 추가
    {
        if (collision.gameObject.CompareTag("Obstacle"))
        {
            SetReward(-0.5f);  // 장애물에 부딪혔을 때 페널티
            EndEpisode();      // 에피소드 종료
        }
    }

}
