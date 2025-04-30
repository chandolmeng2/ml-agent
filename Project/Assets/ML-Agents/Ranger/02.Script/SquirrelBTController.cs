using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SquirrelBTController : MonoBehaviour
{
    public Transform player;
    public Transform plane;

    public float playerSpeed = 5f;
    public float squirrelSpeed = 3f;

    public GameObject obstaclePrefab;
    public int maxObstacles = 6;

    private Rigidbody rb;
    private Rigidbody playerRb;

    private float areaLimitX, areaLimitZ;
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
        // 플레이어는 다람쥐를 추격함
        Vector3 dir = (transform.position - player.position).normalized;
        Vector3 playerNextPos = ClampToPlane(player.position + dir * playerSpeed * Time.deltaTime);
        playerRb.MovePosition(playerNextPos);

        // 잡혔는지 확인
        float dist = Vector3.Distance(transform.position, player.position);
        if (dist < 1.0f)
        {
            Debug.Log("BT: 잡힘");
            ResetEpisode();
        }
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Obstacle"))
        {
            Debug.Log("BT: 장애물 충돌");
            ResetEpisode();
        }
    }

    void ResetEpisode()
    {
        // 위치 초기화
        player.position = GetFarRandomPosition(plane.position, 0.0f);
        transform.position = GetFarRandomPosition(player.position, 2.0f);

        // 장애물 제거
        foreach (var obs in spawnedObstacles)
        {
            if (obs != null) Destroy(obs);
        }
        spawnedObstacles.Clear();

        // 장애물 재생성
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

    void UpdateAreaLimits()
    {
        areaLimitX = (plane.localScale.x * 10f) / 2f - 0.5f;
        areaLimitZ = (plane.localScale.z * 10f) / 2f - 0.5f;
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

    Vector3 ClampToPlane(Vector3 pos)
    {
        float x = Mathf.Clamp(pos.x, plane.position.x - areaLimitX, plane.position.x + areaLimitX);
        float z = Mathf.Clamp(pos.z, plane.position.z - areaLimitZ, plane.position.z + areaLimitZ);
        return new Vector3(x, pos.y, z);
    }
}
