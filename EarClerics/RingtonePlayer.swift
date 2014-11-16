//
//  RingtonePlayer.swift
//  着信音再生用クラス
//
//  Created by hideki on 2014/11/05.
//  Copyright (c) 2014年 hideki. All rights reserved.
//

import Foundation
import AVFoundation
import AudioToolbox

class RingtonePlayer: NSObject {
    
    // ボリューム
    var _volume: Float = 0.8
    //
    var _loopCount     = 30
    
    var _ringtone: String = ""
    
    // 別クラスに移譲すべき
    var _soundPlayer: SoundPlayer = SoundPlayer()

    var _playsVibe = true
    
    var _timer: NSTimer?
    
    // 初期化
    override init() {
        super.init()
        _ringtone  = DEFAULT_RINGTONE
        _volume    = DEFAULT_RINGTONE_VOLUME
        _loopCount = RINGTONE_LOOP_COUNT
        
        _ringtone = "mgs忍者"
        
        var nc :NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        nc.addObserverForName("startRingtone", object: nil, queue: nil, usingBlock: {
            (notification: NSNotification!) in
            self.startRingtone()
        })
        
        nc.addObserverForName("stopRingtone", object: nil, queue: nil, usingBlock: {
            (notification: NSNotification!) in
            self.stopRingtone()
        })
    }
    
    
    // 着信音が鳴っているか
    func isAlarmRinging() -> Bool {
        if _soundPlayer.isBgmPlaying() {
            println("アラーム鳴っとるねん(｀・ω・´)")
            return true
        }
        
        println("アラーム鳴ってへんで(´・ω・`)")
        return false
    }
    
    // 着信音を鳴らす
    func startRingtone() {
        if _playsVibe == true {
            _timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "playVibe:", userInfo: nil, repeats: true)
        }
        _soundPlayer.playBgm(_ringtone, volume: _volume, numberOfLoops: _loopCount)

    }
    
    // バイブレーションスタート
    func playVibe(timer: NSTimer) {
        AudioServicesPlaySystemSound(1011)
        //AudioServicesPlaySystemSound(1352)
    }
    
    // 着信音を停止
    func stopRingtone() {
        _timer?.invalidate()
        _timer = nil
        
        if _soundPlayer.isBgmPlaying() {
            _soundPlayer.playVoice(RESPOND_PHONE_SE)
            _soundPlayer.stopBgm()
            // 通知作成

            //NSNotificationCenter.defaultCenter().postNotificationName("startMorningCall", object: nil)
        }
    }

}