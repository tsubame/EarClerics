//
//  MorningCallPlayer.swift
//  着信音後のモーニングコールを流すクラス
//
//  Created by hideki on 2014/11/05.
//  Copyright (c) 2014年 hideki. All rights reserved.
//

import Foundation
import AVFoundation


class MorningCallPlayer: NSObject {
    
// キャラ別のボイス 別ファイルへ出す
    let _allMessages: Dictionary<String, Array<Array<String>>> = [
        "琴里": [
            ["m-まだ寝ぼけているの.wav", "まだ寝ぼけているの？　こら、しっかりしなさい。"],
            ["m-03.wav", "あまり遊んでばかりじゃだめよ？　ほどほどにね。"],
        ],
        "うさぎさん": [
            ["m-00.mp3", "ふふっ、おはようございます"],
            ["m-02.wav", "あなたが精一杯努力をつくせるように、応援しているわ。"],
            ["m-ごきげんよう、またね.wav", "ごきげんよう、またね"],
        ],
        "どS少女": [
            ["mb-00.wav", "おはようございます。随分遅かったのね。愚鈍"],
            ["mb-01.wav", "それで？　まだ起き上がることもできないの？"],
            //["mb-02.wav", "笑ってしまうほど愚かね、お前。"],
            //["mb-03.wav", "それくらいで努力しているつもりなの？　ばかばかしいわね。"],
            ["mb-04.wav", "緩慢すぎるのではなくて？　少しは焦ったらどうなの。"],
        ],
        "絢辻詞": [
            ["絢辻詞-1.mp3", ""],
            ["絢辻詞-2.mp3", ""],
            ["絢辻詞-3.mp3", ""],
            ["絢辻詞-4.mp3", ""]
        ],
        "七咲逢": [
            ["七咲逢-1.mp3", ""],
            ["七咲逢-2.mp3", ""],
            ["七咲逢-3.mp3", ""],
            ["七咲逢-4.mp3", ""]
        ],
        "森島はるか": [
            ["森島はるか-1.mp3", ""],
            ["森島はるか-2.mp3", ""],
            ["森島はるか-3.mp3", ""],
            ["森島はるか-4.mp3", ""]
        ],
        "棚町薫": [
            ["棚町薫-1.mp3", ""],
            ["棚町薫-2.mp3", ""],
            ["棚町薫-3.mp3", ""],
            ["棚町薫-4.mp3", ""]
        ],
        "菜々子先生": [
            ["菜々子先生-1.mp3", ""],
            ["菜々子先生-2.mp3", ""],
        ],
    ]

// 通話切断音
let ENDCALL_SOUND = "通話切断音.mp3"
    // 再生前のラグ 秒数
    let WAIT_SEC_BEFORE_PLAY_MC: Double = 1.1
    
    // 再生するボイス
    var _playVoices = Array<String>()
    // 再生するボイス（文章）
    var _playTexts  = Array<String>()
    // 再生時の画像
    var _playImages = Array<String>()
    // 再生中の配列のインデックス番号
    var _msgIndex = 0
    //　キャラクター
    var _chara: String = ""
    // ボイスのボリューム
    var _voiceVolume: Float = 0.5
    
    // メッセージ終了監視用タイマー
    var _monitorTimer: NSTimer?
    // 音声再生用
    var _soundPlayer: SoundPlayer = SoundPlayer()
    
    
// テスト用
    let PLAYS_RANDOME = true
    
// 音声再生用
//var _voicePlayer = AVAudioPlayer()

    // イニシャライザ
    override init() {
        super.init()
        // 通知リスナー
        var nc :NSNotificationCenter = NSNotificationCenter.defaultCenter()
        nc.addObserverForName("startMorningCall", object: nil, queue: nil, usingBlock: {
            (notification: NSNotification!) in
            self.startMorningCall()
        })
        
        nc.addObserverForName("stopMorningCall", object: nil, queue: nil, usingBlock: {
            (notification: NSNotification!) in
            self.stopMorningCall()
        })
    }
    
    
    
    // モーニングコールを流す
    func startMorningCall() {
        println("モーニングコールスタート！")
        setting()
        // 再生前のラグ
        let delay = WAIT_SEC_BEFORE_PLAY_MC * Double(NSEC_PER_SEC)
        let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        //self.playRandomeVoice()
        
        dispatch_after(time, dispatch_get_main_queue(), {
            // ランダムでボイスを１つ再生
            if self.PLAYS_RANDOME {
                self.playRandomeVoice()
            } else {
                // タイマーを起動
                self._monitorTimer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "autoPlayNextVoice:", userInfo: nil, repeats: true)
            }
        })
    }
    
    // １つのボイスだけをランダムで流す
    func playRandomeVoice() {
        var count = _playVoices.count
        var index = Int(arc4random_uniform(UInt32(count)))
        let playVoice = _playVoices[index]
        _playVoices = Array<String>()
        _playVoices.append(playVoice)
        
        self._monitorTimer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "autoPlayNextVoice:", userInfo: nil, repeats: true)
    }
    
    // モーニングコールを停止
    func stopMorningCall() {
        stopVoices()
        _monitorTimer?.invalidate()
        _monitorTimer = nil
    }
    
    // モーニングコール前の初期設定
    func setting() {
        _msgIndex = 0
        // ボイス音量
        _voiceVolume = DEFAULT_VOICE_VOLUME
        // 選択中のキャラクター
        var pref = NSUserDefaults.standardUserDefaults()
        var chara: String? = pref.stringForKey("selectedChara")
        _chara = chara!
        // 再生用ボイスを選択
        pickupPlayVoices()
    }
    
    // 再生用ボイスを配列に
    func pickupPlayVoices() {
        _playTexts  = Array<String>()
        _playVoices = Array<String>()
        // キャラクターのボイスを取り出す
        var charMsgs = _allMessages[_chara]!
        
        for row in charMsgs {
            let file = row[0]
            let msg  = row[1]
            _playVoices.append(file)
            _playTexts.append(msg)
        }
        //println(_playVoices)
        println("再生するファイルのリストです")
        println(_playVoices)
    }
    
    // ボイス再生終了後に次のボイスを流す
    func autoPlayNextVoice(timer: NSTimer) {
        // ボイス再生中なら終了
        if _soundPlayer.isVoicePlaying() {
            return
        }
        
        if _msgIndex < _playVoices.count {
            playNextVoice()
        } else {
            println("メッセージ再生終了です")
            // タイマーを停止
            _monitorTimer?.invalidate()
            _monitorTimer = nil
            // 切断音
            //let volume: Float = 0.2
            //_soundPlayer.playVoice(ENDCALL_SOUND, volume: volume)
        }
    }
    
    // 次のボイスを再生
    func playNextVoice() {
        if _playVoices.count <= _msgIndex {
            return
        }
        println("次のボイスを流します\(_msgIndex)")
        let fileName = _playVoices[_msgIndex]
        //playVoice(_playVoices[_msgIndex])
        _soundPlayer.playVoice(fileName)
        _msgIndex++
    }
    
    // ボイスの停止
    func stopVoices() {
        if _monitorTimer != nil {
            if _soundPlayer.isVoicePlaying() {
                _soundPlayer.stopVoice()
            }

            // 切断時の声を流す
            //playVoice(DISCONNECT_VOICE)
            //_msgIndex = 0
            //pickupPlayVoices()
        }
        
        if _soundPlayer.isVoicePlaying() {
            _soundPlayer.stopVoice()
        }
    }
    
    //
    func getNextText() -> String? {
        //
        if _playVoices.count <= _msgIndex {
            //
            return nil
        }
        
        return _playTexts[_msgIndex]
    }

}