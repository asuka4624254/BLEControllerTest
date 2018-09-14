using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class SampleSceneController : MonoBehaviour {

	[SerializeField] private GameObject MenuButton;
	[SerializeField] private GameObject ControllerButton;
	[SerializeField] private GameObject BackButtonFromDisplay;
	[SerializeField] private GameObject BackButtonFromController;
	[SerializeField] private GameObject Cube;

	private BluetoothManager manager = new BluetoothManager();

	[DllImport("__Internal")] // Swiftのメソッドを使用できるようにする
	private static extern void BCConnectAsCentral(string gameObjectName);　// Objective-C経由でSwiftのメソッドを呼び出す

	[DllImport("__Internal")]
	private static extern void BCDisconnect();

	[DllImport("__Internal")]
	private static extern void BCWriteValue(string value);
	
	[DllImport("__Internal")]
	private static extern void BPStartAdvertise(string value);
	
	[DllImport("__Internal")]
	private static extern void BPStopAdvertise();

	// Use this for initialization
	void Start () {

	}
	
	// Update is called once per frame
	void Update () {
		
	}

	// 画面遷移
	public void OnClick() {
#if UNITY_IOS && !UNITY_EDITOR
		string name = EventSystem.current.currentSelectedGameObject.name;
		manager.debugLog(name);

		switch (name) {
			// ディスプレイを表示
			case "DisplayButton":
				MenuButton.SetActive(false);
				Cube.SetActive(true);
				BackButtonFromDisplay.SetActive(true);
				
				BPStartAdvertise("BluetoothManager"); // ペリフェラルとしてBluetooth接続
				break;
			// コントローラを表示
			case "ControllerButton":
				MenuButton.SetActive(false);
				ControllerButton.SetActive(true);
				BackButtonFromController.SetActive(true);

				BCConnectAsCentral("BluetoothManager"); // セントラルとしてBluetooth接続
				break;
			// 左下の戻るボタン
			case "BackButtonFromDisplay":
				MenuButton.SetActive(true);
				Cube.SetActive(false);
				ControllerButton.SetActive(false);
				BackButtonFromDisplay.SetActive(false);
				BackButtonFromController.SetActive(false);

				BPStopAdvertise(); // アドバタイズ停止
				break;
			// 左下の戻るボタン
			case "BackButtonFromController":
				MenuButton.SetActive(true);
				Cube.SetActive(false);
				ControllerButton.SetActive(false);
				BackButtonFromDisplay.SetActive(false);
				BackButtonFromController.SetActive(false);

				BCDisconnect(); // 接続解除
				break;
			case "Left":
				BCWriteValue("Left");
				break;
			case "Right":
				BCWriteValue("Right");
				break;
		}
#else
		manager.debugLog("iOS端末で実行してください");
#endif
	}
}
