//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

// このファイルは、XcodeでSwiftのファイルを新規追加したときに自動生成されたもの（生成するかどうかのダイアログが出た）
// 
// 「Build Settings -> Swift Compiler - General -> Objective-C Bridging Header」の値が
// $(SRCROOT)/Libraries/Plugins/iOS/Unity-iPhone-Bridging-Header.h（このファイルへのパス）
// になっていることを確認すること

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UnityInterface.h" // <- これを追加するだけで UnitySendMessage() が使えるようになる