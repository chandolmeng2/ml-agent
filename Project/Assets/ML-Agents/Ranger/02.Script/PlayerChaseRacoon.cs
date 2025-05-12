using UnityEngine;
using UnityEngine.AI;

public class PlayerChaseRacoon : MonoBehaviour
{
    public Transform racoonTarget;
    private NavMeshAgent agent;

    void Start()
    {
        agent = GetComponent<NavMeshAgent>();
    }

    void Update()
    {
        if (racoonTarget != null)
        {
            agent.SetDestination(racoonTarget.position);
        }
    }
}
