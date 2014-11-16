//
//  LocationGetter.swift
//
//  位置情報を取得するクラス　天気取得前に実行
//
//  Created by hideki on 2014/11/06.
//  Copyright (c) 2014年 hideki. All rights reserved.
//

import Foundation
import CoreLocation

class LocationGetter: NSObject, CLLocationManagerDelegate {
    
    var _locManager: CLLocationManager?
    // 緯度
    var _latitude:   CLLocationDegrees = 0.0
    // 経度
    var _longitude:  CLLocationDegrees = 0.0
    
    //var _heading:    CLLocationDirection = 0.0
    
    var _timer: NSTimer?
    
    // この秒数以内に取得できなければ終了
    let MAX_EXEC_SECOND: Int = 5
    //
    var _timerExecCount = 0
    // 位置情報が取得できるか
    var _canGetLocation: Bool = false
    
    
    // 初期処理
    override init() {
        super.init()
        // ロケーションマネージャーの作成
        _locManager  = CLLocationManager()
        // iOS8のみ以下の処理が必要
        if NSFoundationVersionNumber_iOS_7_1 < floor(NSFoundationVersionNumber) {
            //println("iOS 8で起動中")
            _locManager?.requestAlwaysAuthorization()
        }
        _locManager?.delegate = self
        
        // 通知監視用
        var nc :NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        nc.addObserverForName("startUpdateLocation", object: nil, queue: nil, usingBlock: {
            (notification: NSNotification!) in
            self.startUpdateLocation()
        })
    }
    
    // 位置情報を取得開始
    func startUpdateLocation() {
        // 位置情報の取得開始
        if CLLocationManager.locationServicesEnabled() {
            println("位置情報を取得しに行きます")
            _canGetLocation = true
            _latitude  = 0.0
            _longitude = 0.0
            // 位置情報を取得
            _locManager?.startUpdatingLocation()
            // タイマーを起動
            self._timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "doesGetLocationCompleted:", userInfo: nil, repeats: true)
        } else {
            println("位置情報が取得できません")
        }
    }
    
    func doesGetLocationCompleted(timer: NSTimer) {
        _timerExecCount++
        
        if _latitude != 0.0 || MAX_EXEC_SECOND * 10 <= _timerExecCount {
            _timer?.invalidate()
            _timer = nil
            stopUpdateLocation()
        }
    }
    
    func stopUpdateLocation() {
        println("位置情報の更新を停止します")
        if CLLocationManager.locationServicesEnabled() {
            _locManager?.stopUpdatingLocation()
        }
        
        // 設定情報に書き込み
        // 設定情報に書きこみ
        var pref = NSUserDefaults.standardUserDefaults()
        pref.setObject("\(_latitude)",  forKey: "latitude")
        pref.setObject("\(_longitude)", forKey: "longitude")
        pref.synchronize()
    }
        
    // 位置情報を返す
    func getLocation() -> (CLLocationDegrees, CLLocationDegrees) {
        return (_latitude, _longitude)
    }

    
    //===========================================================
    // CLLocationManagerDelegate
    //===========================================================
    
    // 位置情報更新時に呼ばれる
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations[0] as CLLocation
        println("位置情報を取得しました")
        _latitude  = location.coordinate.latitude
        _longitude = location.coordinate.longitude
        
        println("\(_latitude) \(_longitude)")
    }
    
    // 位置情報取得失敗時に呼ばれる
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        NSOperationQueue.mainQueue().addOperationWithBlock{
            println("位置情報を取得できませんでした")
        }
    }
    
    // 方位情報更新時に呼ばれる
    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        println("方位情報を取得しました")
        //_heading = newHeading.trueHeading
    }
    
    
}