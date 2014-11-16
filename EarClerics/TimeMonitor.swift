//
//  TimeMonitor.swift
//  アラームセット時に時刻を監視するクラス
//
//  Created by hideki on 2014/11/05.
//  Copyright (c) 2014年 hideki. All rights reserved.
//


import UIKit
import Foundation
import AVFoundation

class TimeMonitor: NSObject {
    
    // タイマーの実行インターバル　（秒数）
    let MONITOR_TIMER_INTERVAL: Double = 60.0
    // 設定情報
    var _pref = NSUserDefaults.standardUserDefaults()
    // 監視用タイマー
    var _monitorTimer: NSTimer?
    
    var _countDownTimer: NSTimer?
    
    var _soundPlayer: SoundPlayer = SoundPlayer()

    // 初期化
    override init() {
        super.init()

        var nc :NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        nc.addObserverForName("setAlarmOn", object: nil, queue: nil, usingBlock: {
            (notification: NSNotification!) in
            self.startTimeMonitor()
        })
        nc.addObserverForName("setAlarmOff", object: nil, queue: nil, usingBlock: {
            (notification: NSNotification!) in
            self.cancelAlarm()
        })
    }
    
    // 監視用タイマー起動
    func startTimeMonitor() {
        println("時刻監視用タイマーを起動しました")

    //println("位置情報を取得します")
    //NSNotificationCenter.defaultCenter().postNotificationName("startUpdateLocation", object: nil)
        var lGetter = LocationGetter()
        lGetter.startUpdateLocation()
        
        
        // 無音ファイルを再生
        _soundPlayer.playNoSound()
        // タイマーを起動
        _monitorTimer = NSTimer.scheduledTimerWithTimeInterval(MONITOR_TIMER_INTERVAL, target: self, selector: "checkCurrentTime:", userInfo: nil, repeats: true)
        //
        checkCurrentTime(_monitorTimer!)
    }
    
    // 現在時刻を確認し、アラーム時刻と比較
    func checkCurrentTime(timer: NSTimer) {
        println("時刻監視用タイマー実行中...")
        
        // 現在時刻がアラーム時刻なら着信音を鳴らす
        if isNowEqualsAlarmTime() {
            startRingtone()
            _monitorTimer?.invalidate()
            _monitorTimer = nil
            
            println("1つ目のタイマーを停止しました")
        // 1分後がアラーム時刻ならカウントダウン
        } else if isNextMinuteEqualsAlarmTime() {
            println("残り1分ありません。カウントダウンを始めます")
            println("カウントダウン用タイマーを起動しました")

// タイミングはもう少し考えたほうが良い
            println("お天気を取得します")
            NSNotificationCenter.defaultCenter().postNotificationName("updateWeather", object: nil)
            
            _countDownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "countDown:", userInfo: nil, repeats: true)
            _monitorTimer?.invalidate()
            _monitorTimer = nil
            
            println("1つ目のタイマーを停止しました")
        }
    }
    
    // 現在時刻がアラーム時刻かを判定
    func isNowEqualsAlarmTime() -> Bool {
        // 現在時刻を取得
        var nowTimeStr = getTimeStrFromDate(NSDate())
        // アラーム時刻を取得
        var alartTimeStr = _pref.stringForKey("alarmTime")!
        println("ただいまの時刻は\(nowTimeStr)です。")
        println("アラームの時刻は\(alartTimeStr)です。")
        
        if nowTimeStr == alartTimeStr {
            return true
        }
        
        return false
    }
        
// タイマー間隔によって書きなおす必要あり
    // 1分後の時刻がアラーム時刻かを判定
    func isNextMinuteEqualsAlarmTime() -> Bool {
        // 1分後の時刻を取得
        var nextMinuteTimeStr = getNextMinuteTimeStr()
        // アラーム時刻を取得
        var alartTimeStr = _pref.stringForKey("alarmTime")!
        println("1分後は\(nextMinuteTimeStr)")
        
        if nextMinuteTimeStr == alartTimeStr {
            return true
        }
        
        return false
    }
    
    // カウントダウン処理
    func countDown(timer: NSTimer) {
        // 現在の秒を取得
        let flags = NSCalendarUnit.HourCalendarUnit |
            NSCalendarUnit.MinuteCalendarUnit |
            NSCalendarUnit.SecondCalendarUnit
        
        let cal    = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
        let comps  = cal.components(flags, fromDate: NSDate())
        let second = comps.second
        // 60から現在の秒を引いた数を取得
        var leftSecond = (60 - second) % 60
        println(leftSecond)
        
        // カウントダウンが0になれば着信音を鳴らす
        if leftSecond == 0 {
            startRingtone()
        }
    }
    
    // 着信音を鳴らす
    func startRingtone() {
        // カウントダウンタイマーを停止
        _countDownTimer?.invalidate()
        _countDownTimer = nil
        println("2つ目のタイマーを停止しました")
        println("アラームの時間です。着信音を鳴らします")
        // 通知発行
        NSNotificationCenter.defaultCenter().postNotificationName("startRingtone", object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("showRingingView", object: nil)
        // アラームのセットをオフに
        var pref = NSUserDefaults.standardUserDefaults()
        pref.setObject("false", forKey: "isAlarmSet")
        pref.synchronize()
        
        
        dispatch_after(3, dispatch_get_main_queue(), {
            self._soundPlayer.stopNoSound()
        })
        
        // 削除するか？　通知音の後に着信音を鳴らしたい場合のみ残す
        //NSThread.sleepForTimeInterval(2)
    }
    
    // アラームキャンセル　オフにした時の処理
    func cancelAlarm() {
        println("アラームをキャンセル")
        /*
        if _alarmPlayer.playing {
        _alarmPlayer.stop()
        }*/
        
        _monitorTimer?.invalidate()
        _monitorTimer = nil
        println("1つ目のタイマーを停止しました")
        _countDownTimer?.invalidate()
        _countDownTimer = nil
        println("2つ目のタイマーを停止しました")
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }

    
    //===========================================================
    // AVAudioSessionDelegate
    //===========================================================

    func beginInterruption() {
        println("割り込まれましたぜ(｀・ω・´)")
    }
    
    func endInterruption() {
        println("割り込み終了")
    }
    
// 別クラスへ
    // 時刻のみを文字列で取り出す
    func getTimeStrFromDate(date: NSDate) -> String {
        let fmt = NSDateFormatter()
        fmt.locale = NSLocale(localeIdentifier: "ja_JP") // ロケールの設定
        fmt.dateFormat = "HH:mm"
        var timeStr   = fmt.stringFromDate(date) //"\(comps.hour):\(comps.minute)"
        
        return timeStr
    }
    
    // 1分後の時刻を文字列形式で取得　"07:16" 24時は00時に
    func getNextMinuteTimeStr() -> String {
        let flags =
        NSCalendarUnit.YearCalendarUnit |
            NSCalendarUnit.MonthCalendarUnit |
            NSCalendarUnit.DayCalendarUnit |
            NSCalendarUnit.HourCalendarUnit |
            NSCalendarUnit.MinuteCalendarUnit
        let cal   = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
        let comps = cal.components(flags, fromDate: NSDate())
        
        var hour   = comps.hour
        var minute = comps.minute + 1
        var minuteStr = "\(minute)"
        
        // 1桁なら0を先頭に
        if minute < 10 {
            minuteStr = "0\(minute)"
            // 1分後が60分の時の処理
        } else if minute == 60 {
            minuteStr = "00"
            if hour != 23 {
                hour++
            } else {
                hour = 0
            }
        }
        
        var hourStr = "\(hour)"
        // 1桁なら0を先頭に
        if hour < 10 {
            hourStr = "0\(hour)"
        }
        
        return "\(hourStr):\(minuteStr)"
    }


    

    
}