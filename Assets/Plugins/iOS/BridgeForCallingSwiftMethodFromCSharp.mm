#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h> // ここにこれがないと、ProductName-Swift.h の中で「CBCentralManagerDelegate」が見つからない（Unknown class name 'CBCentralManagerDelegate'; did you mean 'CBCentralManager'?）などと言われる
#import <ProductName-Swift.h>

extern "C" {

    NSString* toNSString(const char* string) {
        return string
            ? [NSString stringWithUTF8String:string]
            : [NSString stringWithUTF8String:""];
    }

    // セントラル（コントローラ側）
    void BCConnectAsCentral(const char* gameObjectName) {
        [[BluetoothCentral alloc] connect:toNSString(gameObjectName)];
    }

    void BCDisconnect() {
        [[BluetoothCentral alloc] disconnect];
    }

    void BCWriteValue(const char* value) {
        [[BluetoothCentral alloc] writeValue:toNSString(value)];
    }
    
    // ペリフェラル（ディスプレイ側）
    void BPStartAdvertise(const char* gameObjectName) {
        [[BluetoothPeripheral alloc] startAdvertise:toNSString(gameObjectName)];
    }
    
    void BPStopAdvertise() {
        [[BluetoothPeripheral alloc] stopAdvertise];
    }
}