using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class BluetoothManager : MonoBehaviour {

	// Use this for initialization
	void Start () {

	}
	
	// Update is called once per frame
	void Update () {
		
	}

	// 右上にデバッグ情報を表示
	public void debugLog(string msg) {
		int max = 2000; // 最大1000文字まで表示
		string text = GameObject.Find("DebugInfo").GetComponent<Text>().text;
		if (text.Length > max) {
			text = text.Substring(0, max);
		}
		GameObject.Find("DebugInfo").GetComponent<Text>().text = msg + "\n" + text;
	}

	// コントローラから送信された値を受け取ってキューブを動かす
	public void moveCube(string direction) {
		if (direction == "Left") {
			GameObject.Find("Cube").transform.Translate(-1, 0, 0);
		}
		else if (direction == "Right") {
			GameObject.Find("Cube").transform.Translate(1, 0, 0);
		}
	}
}
