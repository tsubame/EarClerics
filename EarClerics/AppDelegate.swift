//
//  AppDelegate.swift
//  EarClerics
//
//  Created by hideki on 2014/11/16.
//  Copyright (c) 2014年 Tsubaki. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // 天気取得クラス
    var _weatherGetter: WeatherGetter?
    // 時間監視用クラス
    var _timeMonitor: TimeMonitor?
    // オーディオセッション
    var _audioSession: AVAudioSession = AVAudioSession.sharedInstance()

    
    
    // 通知センターの使用許可を取得　iOSのバージョンで分岐
    func registerNotifSetting(application: UIApplication) {
        // Load resources for iOS 7.0 or earlier
        if floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1 {
            application.registerForRemoteNotificationTypes(UIRemoteNotificationType.Sound | UIRemoteNotificationType.Alert | UIRemoteNotificationType.Badge)
        // Load resources for iOS 8 or later
        } else {
            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Sound | UIUserNotificationType.Alert | UIUserNotificationType.Badge, categories: nil))
        }
    }
    
    // 初期データをNSUserDefaultsに登録
    func registerInitialData() {
        var pref = NSUserDefaults.standardUserDefaults()
        //　選択中のキャラクター
        var selectedChara: String? = pref.stringForKey("selectedChara")
        if selectedChara == nil {
            selectedChara = DEFAULT_CHARACTER
            println("選択キャラがありません。初期データとして \(selectedChara) を登録します")
            pref.setObject(selectedChara, forKey: "selectedChara")
            pref.synchronize()
        }
        // 位置情報がなければ取得
        var latitude : String? = pref.stringForKey("latitude")
        var longitude: String? = pref.stringForKey("longitude")
        if latitude == nil {
            println("位置情報が登録されていません")
            NSNotificationCenter.defaultCenter().postNotificationName("startUpdateLocation", object: nil)
        }
    }
    
    //===========================================================
    // UIApplicationDelegate
    //===========================================================
    
    // 起動時に実行
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // 通知センターの使用準備
        registerNotifSetting(application)
        
        // バックグラウンドで音楽を再生する準備
        _audioSession = AVAudioSession.sharedInstance()
        _audioSession.setCategory(AVAudioSessionCategoryPlayback, withOptions: AVAudioSessionCategoryOptions.MixWithOthers, error: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "sessionDidInterrupt:", name: "AVAudioSessionInterruptionNotification", object: nil)
        
        // インスタンス作成
        
        //_ringtonePlayer    = RingtonePlayer()
        //_morningcallPlayer = MorningCallPlayer()
        //_locationGetter    = LocationGetter()
        _weatherGetter       = WeatherGetter()
        _timeMonitor         = TimeMonitor()
        
        // 初期データの作成
        registerInitialData()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        println("バックグラウンドになりました")
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

