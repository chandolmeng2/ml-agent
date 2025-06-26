using UnityEngine;
using UnityEngine.AI;
using System.Collections.Generic;
using System.IO;

public class NavMesh_Racoon : MonoBehaviour
{
    public Transform player; // 추격자 (자동)
    public float playerSpeed = 5f; // 플레이어 이동 속도
    public Transform plane; // 도주 영역 (평면)
    private NavMeshAgent agent; // NavMesh Agent
    private Rigidbody playerRb;

    private float areaLimitX;
    private float areaLimitZ;

    private float escapeTime = 0f;
    private int collisionCount = 0;
    private bool isSuccess = false;

    private string filePath = "Assets/SimulationResults_NavMesh.csv";

    private void Start()
    {
        agent = GetComponent<NavMeshAgent>();
        playerRb = player.GetComponent<Rigidbody>();

        UpdateAreaLimits();
        InitializeCSV();
        ResetSimulation();
    }

    private void Update()
    {
        if (!isSuccess)
        {
            escapeTime += Time.deltaTime;
            MovePlayer();
            UpdateAgentDestination();
            CheckSuccess();
        }
    }

    private void UpdateAgentDestination()
    {
        Vector3 awayDirection = (transform.position - player.position).normalized;
        Vector3 destination = transform.position + awayDirection * 10f;
        agent.SetDestination(ClampToPlane(destination));
    }

    private void MovePlayer()
    {
        Vector3 direction = (transform.position - player.position).normalized;
        playerRb.MovePosition(player.position + direction * playerSpeed * Time.deltaTime);
    }

    private void CheckSuccess()
    {
        float distanceToPlayer = Vector3.Distance(transform.position, player.position);

        if (distanceToPlayer > 10f) // 도망 성공 기준
        {
            isSuccess = true;
            SaveResult(1, escapeTime, collisionCount);
            ResetSimulation();
        }
        else if (escapeTime >= 30f) // 최대 도망 시간
        {
            SaveResult(0, escapeTime, collisionCount);
            ResetSimulation();
        }
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Player"))
        {
            SaveResult(0, escapeTime, collisionCount);
            ResetSimulation();
        }
        else if (collision.gameObject.CompareTag("Obstacle"))
        {
            collisionCount++;
        }
    }

    private void ResetSimulation()
    {
        // 초기화
        escapeTime = 0f;
        collisionCount = 0;
        isSuccess = false;

        // 플레이어와 AI 위치 초기화
        player.position = GetFarRandomPosition(plane.position, 0.0f);
        transform.position = GetFarRandomPosition(player.position, 2.0f);

        agent.enabled = false;
        agent.enabled = true; // NavMeshAgent 리셋
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

    private void UpdateAreaLimits()
    {
        areaLimitX = (plane.localScale.x * 10f) / 2f - 0.5f;
        areaLimitZ = (plane.localScale.z * 10f) / 2f - 0.5f;
    }

    private void InitializeCSV()
    {
        if (!File.Exists(filePath))
        {
            File.WriteAllText(filePath, "Success,EscapeTime,CollisionCount\n");
        }
    }

    private void SaveResult(int success, float escapeTime, int collisionCount)
    {
        string data = $"{success},{escapeTime},{collisionCount}\n";
        File.AppendAllText(filePath, data);
    }
}
