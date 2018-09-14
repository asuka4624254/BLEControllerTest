//
//  BluetoothCentral.swift
//  Unity-iPhone
//
//  Created by Asuka Inagaki on 2018/09/05.
//

import Foundation
import CoreBluetooth

class BluetoothCentral: NSObject {
    // Xcode9.2 では @objc の記述がなくても ProductName-Swift.h に書き出されていたが、
    // Xcode9.4 では @objc がないと書き出されない！何か設定が必要？

    // 接続開始
    @objc func connect(_ gameObjectName: NSString) {
        _BluetoothCentral.instance.connect(gameObjectName as String)
    }

    // 接続解除
    @objc func disconnect() {
        _BluetoothCentral.instance.disconnect()
    }

    // 値を書き込む
    @objc func writeValue(_ value: NSString) {
        _BluetoothCentral.instance.writeValue(value as String)
    }
}

class _BluetoothCentral: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // シングルトンにしないと「[CoreBluetooth] XPC connection invalid」エラーが出る
    static var instance: _BluetoothCentral = _BluetoothCentral()
    private override init() {}

    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    private var characteristic: CBCharacteristic!

    private var isConnected: Bool = false

    private var gameObjectName: String! // 呼び出すUnityのメソッドがアタッチされているゲームオブジェクト名（今回は「BluetoothManager」）
    
    // 接続するサービス（ペリフェラルで指定したものと同じもの）
    private var serviceUUID: CBUUID = CBUUID(string: "0340A7F1-530A-42A4-8BA8-010ACEF6BFD3")
    // 接続するキャラクタリスティック（ペリフェラルで指定したものと同じもの）
    private var charcteristicUUID: CBUUID = CBUUID(string: "B437C5C2-A638-4CE5-A6D1-0EF63F3D97E1")

    // 接続開始
    func connect(_ gameObjectName: String) {
        self.gameObjectName = gameObjectName;

        // セントラルマネージャを起動
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // 接続解除
    func disconnect() {
        _BluetoothCentral.instance = _BluetoothCentral()
        debugLog("接続を解除しました")
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // 起動直後にスキャンを開始するとスキャンに失敗する
        switch central.state {
            case CBManagerState.poweredOn:
                debugLog("ペリフェラルのスキャンを開始します...")
                // このサービスUUIDを持つペリフェラルをスキャンする
                centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
            default:
                break
        }
    }
    
    // ペリフェラルを検知した場合
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        debugLog("検知したペリフェラル: \(peripheral)")
        
        self.peripheral = peripheral
        // ペリフェラルに接続
        centralManager.connect(peripheral, options: nil)
    }
    
    // ペリフェラルへの接続が成功した場合
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        debugLog("\(peripheral) に接続成功しました")
        centralManager.stopScan() // ストップしないと接続後もスキャンし続ける
        
        // サービスを検出する
        self.peripheral.delegate = self
        self.peripheral.discoverServices([serviceUUID])
    }
    
    // ペリフェラルへの接続に失敗した場合
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        debugLog("\(peripheral) に接続失敗しました: \(error.debugDescription)")
    }
    
    // サービスを見つけた場合
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            debugLog("サービスの検出でエラーが発生しました: \(error.debugDescription)")
            return
        }
        // キャラクタリスティックを検出する
        // 今回の仕様では、相手がひとつしかサービスを持たないため「.first」としている
        self.peripheral.discoverCharacteristics([charcteristicUUID], for: (peripheral.services?.first)!)
    }
    
    // キャラクタリスティックを見つけた場合
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            debugLog("キャラクタリスティックの検出でエラーが発生しました: \(error.debugDescription)")
            return
        }
        debugLog("キャラクタリスティックを検出しました")

        // 今回の仕様では、相手がひとつしかキャラクタリスティックを持たないため「.first」としている
        characteristic = service.characteristics?.first
        isConnected = true; // キャラクタリスティックを見つけられればデータの送受信ができる
    }

    // 値を書き込む
    func writeValue(_ value: String) {
        if !isConnected { return }
        
        let data: Data = value.data(using: .utf8)!
        peripheral.writeValue(data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
        debugLog("「\(value)」を書き込みました")
    }

    func debugLog(_ msg: String) {
        print(msg)
        // Unityのメソッドを呼び出し
        UnitySendMessage(gameObjectName, "debugLog", msg) // Unityのゲームオブジェクト gameObjectName にアタッチされているスクリプトの中の「debugLog」というメソッドを、msg を引数にして呼び出す
    }
}