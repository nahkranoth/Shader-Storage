using UnityEngine;
using System.Collections;

public class timeSeed : MonoBehaviour {

    public Material mat;
    public float timer;
    private float time;
    
	void Start () {
        StartCoroutine(RunTimer());
    }


    IEnumerator RunTimer()
    {
        while (true)
        {
            time += timer;
            mat.SetFloat("_SeedTimer", time);
            yield return new WaitForSeconds(timer);
        }
    }
}
