//
//  BluetoothPeripheral.swift
//  Unity-iPhone
//
//  Created by Asuka Inagaki on 2018/09/05.
//

import Foundation
import CoreBluetooth

class BluetoothPeripheral: NSObject {
    // Xcode9.2 では @objc の記述がなくても ProductName-Swift.h に書き出されていたが、
    // Xcode9.4 では @objc がないと書き出されない！何か設定が必要？
    
    // アドバタイズ開始
    @objc func startAdvertise(_ gameObjectName: NSString) {
        _BluetoothPeripheral.instance.prepare(gameObjectName as String)
    }
    
    // アドバタイズ停止
    @objc func stopAdvertise() {
        _BluetoothPeripheral.instance.stopAdvertise()
    }
}

class _BluetoothPeripheral: NSObject, CBPeripheralManagerDelegate {
    
    // シングルトンにしないと「[CoreBluetooth] XPC connection invalid」エラーが出る
    static let instance: _BluetoothPeripheral = _BluetoothPeripheral()
    private override init() {}
    
    private var peripheralManager: CBPeripheralManager!
    private var service: CBMutableService!
    private var characteristic: CBMutableCharacteristic!
    
    private var gameObjectName: String! // 呼び出すUnityのメソッドがアタッチされているゲームオブジェクト名（今回は「BluetoothManager」）
    
    // パブリッシュするサービス
    private var serviceUUID: CBUUID = CBUUID(string: "0340A7F1-530A-42A4-8BA8-010ACEF6BFD3")
    // パブリッシュするキャラクタリスティック
    private var charcteristicUUID: CBUUID = CBUUID(string: "B437C5C2-A638-4CE5-A6D1-0EF63F3D97E1")
    
    // アドバタイズを開始
    func prepare(_ gameObjectName: String) {
        self.gameObjectName = gameObjectName;
        
        // ペリフェラルマネージャを起動
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    // アドバタイズを停止
    func stopAdvertise() {
        peripheralManager.stopAdvertising()
        debugLog("アドバタイズを停止しました")
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        // 起動直後にアドバタイズを開始すると失敗する
        switch peripheral.state {
        case CBManagerState.poweredOn:
            debugLog("アドバタイズを開始します...")
            startAdvertise()
        default:
            break
        }
    }
    
    func startAdvertise() {
        // サービスを作成
        service = CBMutableService(type: serviceUUID, primary: true) // primary -> 主となるサービスとするかどうか
        // キャラクタリスティックを作成
        characteristic = CBMutableCharacteristic(
            type: charcteristicUUID,
            properties: [.read, .write],
            value: nil,
            permissions: [.readable, .writeable])
        // サービスにキャラクタリスティックを設定
        service.characteristics = [characteristic]
        // サービスをペリフェラルマネージャに追加
        peripheralManager.add(service)
        
        // アドバタイズ開始
        peripheralManager.startAdvertising([
            CBAdvertisementDataLocalNameKey: "Display",
            CBAdvertisementDataServiceUUIDsKey: [serviceUUID]
        ])
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        if error != nil {
            debugLog("サービスの追加に失敗しました: \(error.debugDescription)")
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if error != nil {
            debugLog("アドバタイズに失敗しました: \(error.debugDescription)")
        }
    }
    
    // 書き込みリクエストに応答して、値を書き込む
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            if request.characteristic.uuid.isEqual(characteristic.uuid) {
                // リクエストの値を書き込む
                characteristic.value = request.value
                
                let value: String? = String(data: request.value!, encoding: .utf8)
                debugLog("「\(value as! String)」を書き込みました")
                UnitySendMessage(gameObjectName, "moveCube", value) // Unityのメソッドを呼び出し
            }
        }
        // リクエストに応答
        peripheralManager.respond(to: requests[0], withResult: .success)
    }
    
    func debugLog(_ msg: String) {
        print(msg)
        // Unityのメソッドを呼び出し
        UnitySendMessage(gameObjectName, "debugLog", msg) // Unityのゲームオブジェクト gameObjectName にアタッチされているスクリプトの中の「debugLog」というメソッドを、msg を引数にして呼び出す
    }
}
