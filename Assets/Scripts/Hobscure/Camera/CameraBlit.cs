using UnityEngine;
using System.Collections;

namespace Hobscure.Camera {
    [ExecuteInEditMode]
    public class CameraBlit : MonoBehaviour {

    public Material mat;

        void Update()
        {
           
        }

        void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            mat.SetFloat("_Seed", Time.time);
            Graphics.Blit(src, dest, mat);
        }
    }
}
