using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Webcam : MonoBehaviour {

	WebCamTexture camTexture;
	Material material;


	// Use this for initialization
	void Start () {
		// foreach (WebCamDevice device in WebCamTexture.devices) {
		// 	print("camera: " + device.name);
		// }
		camTexture = new WebCamTexture();
		camTexture.requestedWidth = 1280;
		camTexture.requestedHeight = 720;
		camTexture.requestedFPS = 30;

		// renderer.material.mainTexture = camTexture;
		material = this.GetComponent<Renderer>().material;
		material.mainTexture = camTexture;
		
		camTexture.Play();
	}
	
	// Update is called once per frame
	void Update () {
		// Color[] pixels = camTexture.GetPixels();
		// print(pixels.Length); // 921600 // 1280x720

		float ratio = (float)camTexture.width / (float)camTexture.height;
		Vector3 scale = this.transform.localScale;
		this.transform.localScale = new Vector3(-1 * scale.y * ratio, scale.y, scale.z);
		// print("width: " + camTexture.width + " height: " + camTexture.height + " ratio: " + ratio + " fps: " + 1.0 / Time.smoothDeltaTime);
		// print("fr: " + camTexture)

		float t = Time.time / 2;
		int compositionIndex = (int)(t % 3f);
		float compositionTime = t % 10f;
		float instructionTime = t % 3f;
		// print("i " + compositionIndex + " ct " + compositionTime + " it " + instructionTime);
		material.SetInt("hypno_compositionIndex", compositionIndex);
		material.SetFloat("hypno_compositionTime", compositionTime);
		material.SetFloat("hypno_instructionTime", instructionTime);
	}
}
