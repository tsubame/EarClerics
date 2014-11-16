//
//  TextTestViewController.swift
//  TamiTami
//
//  Created by hideki on 2014/11/15.
//  Copyright (c) 2014年 hideki. All rights reserved.
//

import Foundation
import UIKit
//import Promise

class T: UIViewController {
    
    //@IBOutlet weak var _messageLabelText: LTMorphingLabel!
    
    @IBOutlet weak var _textLabel: TTTAttributedLabel!
    var _mcPlayer: MorningCallPlayer = MorningCallPlayer()
    
    var _messages = [
        "（。・ω・）ノ゛ 今茶♪ \n　お兄さま、疲れていませんか？",
        "【拡散＆宣伝】神村ひな＆nico企画♪ブログ「リリとメメ」11/14（第19回）更新しました！今週は神村のお当番です☆　→http://hinanico.o-oi.net  ",
        "神村、今回はすぐ動かなくなるツンデレさんフリーソフトを何とかいじって頑張ったぁ；；よかったら遊びにきてね♪",
        "あらーインテルの\nマッツァーリさんが。長友元気かなー。絶好調な時もあれば、いまいちうまくいかない時もあれば。"
    ]
    
    var _msgIndex = 0
    
    
    var _showCharTimer: NSTimer?
    //var _showingText
    let MONITOR_TIMER_INTERVAL = 0.015
    
    var _fullText = ""
    
    var _charCount = 0
    var _chars  = [Character]()
    var _labels = [UILabel]()
    
    var _isMessageEnded = true
    
    @IBAction func _testButtonClicked(sender: AnyObject) {
        if _messages.count <= _msgIndex {
            _msgIndex = 0
        }
        _fullText = _messages[_msgIndex]
        
        showTextWithFade(_labels, text: _fullText)
        _msgIndex++
    }
    
    func showTextWithFade(labels: Array<UILabel>, text: String) {
        if !_isMessageEnded {
            return
        }
        
        _isMessageEnded = false
        
        _chars = [Character]()
        for ch in text {
            _chars.append(ch)
        }
        
        // 前の文字列を削除
        for (index, label) in enumerate(labels) {
            label.text = "　"
        }
        
        let DELAY_TIME = 0.025
        let CHAR_FADE_DURATION = 0.8
        
        for (index, label) in enumerate(labels) {
            if _chars.count <= index {
                break
            }
            var labelText = String(_chars[index])
            var delayTime = Double(index) * DELAY_TIME
            
            delay(delayTime, {
                UIView.transitionWithView(label,
                    duration: CHAR_FADE_DURATION,
                    options: UIViewAnimationOptions.TransitionCrossDissolve,
                    animations: {
                        label.text = labelText
                    },
                    completion: {
                        finished in
                        self.checkEndMessage(index)
                })
            })
        }
    }
    
    func checkEndMessage(index: Int) {
        if _chars.count - 1 <= index || _labels.count - 1 <= index {
            self._isMessageEnded = true
        }
    }
    
    var _isMessageFinished = false
    
    func showTextWithAnim() {
        UIView.transitionWithView(self._textLabel,
            duration: 0.02,
            options: UIViewAnimationOptions.TransitionCrossDissolve,
            animations: {
                self.showNextChar()
            },
            completion: {
                finished in
                if self._isMessageFinished == false {
                    self.showTextWithAnim()
                }
        })
    }
    
    func showNextChar() {
        var labelText = _textLabel.text!
        
        if _charCount < countElements(_fullText) {
            _charCount++
            //println(labelText)
            var showText = (_fullText as NSString).substringToIndex(_charCount)
            //println(showText)
            
            self._textLabel.text = showText
            
        } else {
            println("文字表示を終了しました。")
            _isMessageFinished = true
        }
    }
    
    func startAnim(sender: AnyObject) {
        _textLabel.text = ""
        println("アニメーション始まったで")
    }
    
    func endAnim(animID: String, finished: Bool, context: AnyObject) {
        if _messages.count <= _msgIndex {
            _msgIndex = 0
        }
        
        var text = _messages[_msgIndex]
        _msgIndex++
        _textLabel.text = text
        println("アニメーション終ったで")
    }
    
    func showTextAsTypeWriter(text: String) {
        _textLabel.text = ""
        _charCount = 0
        _fullText = text
        // タイマーを起動
        if let isNotNull = _showCharTimer {
            return
        }
        _showCharTimer = NSTimer.scheduledTimerWithTimeInterval(MONITOR_TIMER_INTERVAL, target: self, selector: "showTextByChar:", userInfo: nil, repeats: true)
        println("タイマーを起動しました。")
    }
    
    func showTextByChar(timer: NSTimer) {
        println("タイマー実行中…")
        var labelText = _textLabel.text!
        
        if _charCount < countElements(_fullText) {
            _charCount++
            
            var showText = (_fullText as NSString).substringToIndex(_charCount)
            
            self._textLabel.text = ""
            
            UIView.transitionWithView(self._textLabel,
                duration: 1.0,
                options: UIViewAnimationOptions.TransitionCrossDissolve,
                animations: {
                    self._textLabel.text = showText
                },
                completion: {
                    finished in
                    println("アニメ終ったでー")
            })
            
            //_textLabel.text = showText
            
            println(showText)
        } else {
            println("タイマーを停止しました。")
            _showCharTimer?.invalidate()
            _showCharTimer = nil
            //_textLabel.sizeToFit()
        }
    }
    
    //===========================================================
    // UI
    //===========================================================
    
    // ビューロード時の処理
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _textLabel.lineSpacing = 1
        _textLabel.verticalAlignment = TTTAttributedLabelVerticalAlignment.Top
        
        // ラベルの作成
        let labelCountInLine = 13
        let lineCount = 4
        
        for var i = 0; i < lineCount; i++ {
            for var j = 0; j < labelCountInLine; j++ {
                let x: CGFloat = CGFloat(j) * 20 + 30
                let y: CGFloat = CGFloat(i) * 26 + 100
                var label = makeLabel(CGPointMake(x, y), text: "あ", font: UIFont.systemFontOfSize(20))
                self.view.addSubview(label)
                _labels.append(label)
            }
        }
    }
    
    func makeLabel(pos: CGPoint, text: NSString, font: UIFont) -> UILabel {
        let label = UILabel()
        label.frame = CGRectMake(pos.x, pos.y, 9999, 9999)
        label.text = text
        label.font = font
        label.textAlignment = NSTextAlignment.Left
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.numberOfLines = 0
        label.sizeToFit()
        
        return label
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    override func viewDidAppear(animated: Bool) {
        //_textLabel.text = "ﾜｯｼｮｲヽ(ﾟ∀ﾟ)メ(ﾟ∀ﾟ)メ(ﾟ∀ﾟ)ノﾜｯｼｮｲ\nﾜｯｼｮｲヽ(ﾟ∀ﾟ)メ(ﾟ∀ﾟ)メ(ﾟ∀ﾟ)ノﾜｯｼｮｲﾜｯｼｮｲヽ(ﾟ∀ﾟ)メ(ﾟ∀ﾟ)メ(ﾟ∀ﾟ)ノﾜｯｼｮｲ"
        //_textLabel.sizeToFit()
    }
    
    // 画面にタッチされた時
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        println("（。・ω・）ノ゛ 今茶♪ ")
        if _messages.count <= _msgIndex {
            _msgIndex = 0
            return
        }
        
        var text = _messages[_msgIndex]
        //showText(text)
        //showTextAsTypeWriter(text)
        showTextAsTypeWriter(text)
        
        //_textLabel.text = text
        //_textLabel.sizeToFit()
        _msgIndex++
        
        var sampleText = "あのー…怖いなあ　ﾜｯｼｮｲヽ(ﾟ∀ﾟ)メ(ﾟ∀ﾟ)メ(ﾟ∀ﾟ)ノﾜｯｼｮｲ\nﾜｯｼｮｲヽ(ﾟ∀ﾟ)メ(ﾟ∀ﾟ)メ(ﾟ∀ﾟ)ノﾜｯｼｮｲ"
        
        
    }
    
    
    
}