//
//  SoundPlayer.swift
//  TamiTami
//
//  Created by hideki on 2014/11/02.
//  Copyright (c) 2014年 hideki. All rights reserved.
//

import Foundation
import AVFoundation

class SoundPlayer: NSObject {

    // 音声再生用
    var _voicePlayer = AVAudioPlayer()
    // BGM再生用
    var _bgmPlayer = AVAudioPlayer()
    // SE再生用
    var _sePlayer = AVAudioPlayer()
    
    var _nosoundPlayer = AVAudioPlayer()
    
    // ダミー用ファイル　必要？
    let DUMMY_FILE = "無音.mp3"
    
    let DEFAULT_BGM_VOLUME: Float = 0.05
    
    //let DEFAULT_VOICE_VOLUME: Float = 0.5
    
    override init() {
        super.init()
        _bgmPlayer   = makeAudioPlayer(DUMMY_FILE)
        _voicePlayer = makeAudioPlayer(DUMMY_FILE)
    }
    
    // 音楽の再生
    func playBgm(fileName: String) {
        let volume: Float = DEFAULT_BGM_VOLUME
        playBgm(fileName, volume: volume)
    }
    
    // 音楽の再生 ボリュームを指定
    func playBgm(fileName: String, volume: Float) {
        _bgmPlayer = makeAudioPlayer(fileName)
        
        if !_bgmPlayer.playing {
            _bgmPlayer.numberOfLoops = 999
            _bgmPlayer.currentTime = 0
            _bgmPlayer.volume = volume
            _bgmPlayer.play()
        }
    }
    
    // 音楽の再生 ボリュームと繰り返し回数を指定
    func playBgm(fileName: String, volume: Float, numberOfLoops: Int) {
        _bgmPlayer = makeAudioPlayer(fileName)
        
        if !_bgmPlayer.playing {
            _bgmPlayer.numberOfLoops = numberOfLoops
            _bgmPlayer.currentTime = 0
            _bgmPlayer.volume = volume
            _bgmPlayer.play()
        }
    }
    
    func isBgmPlaying() -> Bool{
        if _bgmPlayer.playing {
            return true
        }
        
        return false
    }
    
    // 音楽の再生
    func stopBgm() {
        if _bgmPlayer.playing {
            _bgmPlayer.stop()
        }
    }
    
    // 無音ファイルを再生
    func playNoSound() {
        _nosoundPlayer = makeAudioPlayer(NOSOUND_FILE)
        
        if !_nosoundPlayer.playing {
            _nosoundPlayer.numberOfLoops = 2000
            _nosoundPlayer.currentTime   = 0
            _nosoundPlayer.volume = 0.01
            _nosoundPlayer.play()
        }
        
        println("無音ファイルを再生します")
    }
    
    // 無音ファイルを停止
    func stopNoSound() {
        if _nosoundPlayer.playing {
            _nosoundPlayer.stop()
        }
        
        println("無音ファイルを停止します")
    }
        
    // ボイスの再生
    func playVoice(fileName: String) {
        playVoice(fileName, volume: DEFAULT_VOICE_VOLUME)
    }
    
    // ボイスの再生 音量指定付き
    func playVoice(fileName: String, volume: Float) {
        _voicePlayer = makeAudioPlayer(fileName)
        
        if !_voicePlayer.playing {
            _voicePlayer.numberOfLoops = 0
            _voicePlayer.currentTime = 0
            _voicePlayer.volume = volume
            _voicePlayer.play()
        }
    }
    
    // ボイスの停止
    func stopVoice() {
        if _voicePlayer.playing {
            _voicePlayer.stop()
        }
    }
    
    // ボイスが再生中か
    func isVoicePlaying() -> Bool{
        if _voicePlayer.playing {
            return true
        }
        
        return false
    }
    
    // ボイスの再生
    func playSE(fileName: String) {
        playSE(fileName, volume: DEFAULT_VOICE_VOLUME)
    }
    
    // ボイスの再生 音量指定付き
    func playSE(fileName: String, volume: Float) {
        _sePlayer = makeAudioPlayer(fileName)
        
        if !_sePlayer.playing {
            _sePlayer.numberOfLoops = 0
            _sePlayer.currentTime = 0
            _sePlayer.volume = volume
            _sePlayer.play()
        }
    }
    
    // ボイスの停止
    func stopSE() {
        if _sePlayer.playing {
            _sePlayer.stop()
        }
    }
    
    // ボイスが再生中か
    func isSEPlaying() -> Bool{
        if _sePlayer.playing {
            return true
        }
        
        return false
    }
    
    
    // 拡張子を補う
    func supplySuffix(fileName: String) -> String {
        // 拡張子があるか？
        var loc = (fileName as NSString).rangeOfString(".").location
        if loc == NSNotFound {
            for suffix in SOUND_SUFFIXES {
                var fileNameWithSuffix = fileName + suffix
                var path = NSBundle.mainBundle().pathForResource(fileNameWithSuffix, ofType: "")
                
                if path != nil {
                    println("拡張子" + suffix + "を追加しました")
                    return fileNameWithSuffix
                }
            }
            println("拡張子不明ですね(・ω・;)")
        }
        
        return fileName
    }
    
    func makeAudioPlayer(res:String) -> AVAudioPlayer {
        // 拡張子を補う
        let fileName = supplySuffix(res)
        
        var path = NSBundle.mainBundle().pathForResource(fileName, ofType: "")
        if path == nil {
            println("error! ファイルがありません！: " + fileName)
            path = NSBundle.mainBundle().pathForResource(NOSOUND_FILE, ofType: "")
        }
        
        let url  = NSURL.fileURLWithPath(path!)

        return AVAudioPlayer(contentsOfURL: url, error: nil)
    }
}