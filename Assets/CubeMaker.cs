using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CubeMaker : MonoBehaviour {

	public Transform a, b;
	private float width = 0.2f;
	private GameObject bone;

	// Use this for initialization
	void Start () {
		bone = GameObject.CreatePrimitive(PrimitiveType.Cylinder);
		SetPosition(bone, a, b);
	}
	
	// Update is called once per frame
	void Update () {
		SetPosition(bone, a, b);
	}

	void SetPosition(GameObject bone, Transform a, Transform b) {
		Vector3 offset = b.position - a.position;
		Vector3 midpoint = a.position + (offset / 2);

		bone.transform.position = midpoint;
		bone.transform.up = offset;
		bone.transform.localScale = new Vector3(width, offset.magnitude / 2f, width);
	}
}
