//
//  TextPlayer.swift
//  EarClerics
//
//  Created by hideki on 2014/11/16.
//  Copyright (c) 2014年 Tsubaki. All rights reserved.
//

import Foundation

class TextWindowManager: NSObject {

    // 1行の文字数
    var _charCountInLine = 13
    // 行の数
    var _lineCount = 4
    // フォントサイズ
    var _fontSize: Int = 20
    // 行の高さ
    var _lineHeight: Int = 26
    // ウィンドウの左端の座標
    var _windowX: Int = 0
    // ウィンドウの右端の座標
    var _windowY = 0
    // ウィンドウと文字間のマージン
    var _padding = 20
    
    // ラベルの配列　1文字ずつ入る
    var _charLabels = [UILabel]()
    // ウィンドウの背景画像
    var _bgImage = ""
    
    // メッセージを表示し終わっているか
    var _isMessageEnded = true
    
    var _chars = [Character]()
    
    var _currentText = ""
    
    // 次の文字を表示するまでの時間
    let DELAY_TIME = 0.025
    // 1文字がフェードインする時間
    let CHAR_FADE_DURATION = 0.8
    
    //
    override init() {
        super.init()
    }
    
    // ラベルの配列を返す
    func makeCharLabels() -> Array<UILabel> {
        for var i = 0; i < _lineCount; i++ {
            for var j = 0; j < _charCountInLine; j++ {
                // ラベルのX座標
                //let x: CGFloat = CGFloat(j) * _fontSize + 0
                let x: CGFloat = CGFloat(j) * CGFloat(_fontSize) + CGFloat(_windowX)
                // ラベルのY座標
                let y: CGFloat = CGFloat(i) * CGFloat(_lineHeight) + CGFloat(_windowY)
                // ラベル作成
                var label = makeLabel(CGPointMake(x, y), text: "あ", font: UIFont.systemFontOfSize(CGFloat(_fontSize)))
                _charLabels.append(label)
            }
        }
        
        return _charLabels
    }
    
    // メッセージウィンドウを返す
    func makeWindow() {
        
    }
    
    // ラベルの配列を返す
    func makeTextAnimeLabels(x: Int, y: Int, charCountInLine: Int, lineCount: Int, fontSize: Int, lineHeight: Int) -> Array<UILabel> {
        var labels = [UILabel]()
        
        for var i = 0; i < lineCount; i++ {
            for var j = 0; j < charCountInLine; j++ {
                
                let x: CGFloat = CGFloat(j) * 20 + 30
                //let y: CGFloat = CGFloat(i) * lineHeight + 100
                //var label = makeLabel(CGPointMake(x, y), text: "　", font: UIFont.systemFontOfSize(fontSize))
                //self.view.addSubview(label)
                //labels.append(label)
            }
        }
        
        return labels
    }
    
    // 1つのラベルを作成
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
    
    // フェードしながらテキストを表示
    func showTextWithFade(labels: Array<UILabel>, text: String) {
        if !_isMessageEnded {
            return
        } else {
            _isMessageEnded = false
        }
        // 表示中の文字列を削除
        clearLabelsText(labels)
        // 文字列を分解して文字の配列に
        _chars = stringToChars(text)
        
        for (index, label) in enumerate(labels) {
            if _chars.count <= index {
                break
            }
            
            var labelText = String(_chars[index])
            var delayTime = Double(index) * DELAY_TIME
            
            delay(delayTime, {
                UIView.transitionWithView(label,
                    duration: self.CHAR_FADE_DURATION,
                    options: UIViewAnimationOptions.TransitionCrossDissolve,
                    animations: {
                        label.text = labelText
                    },
                    completion: {
                        finished in

                        if self._chars.count - 1 <= index || labels.count - 1 <= index {
                            self._isMessageEnded = true
                        }
                })
            })
        }
    }
    
    func clearLabelsText(labels: Array<UILabel>) {
        for (index, label) in enumerate(labels) {
            label.text = "　"
        }
    }
    
    // テキストを文字に分解して配列に
    func stringToChars(text: String) -> Array<Character>{
        var chars = [Character]()
        for ch in text {
            chars.append(ch)
        }
        
        return chars
    }
    
    func checkEndMessage(index: Int) {
        
    }
    
    //===========================================================
    // アクセッサ
    //===========================================================
    
    func setWindowX(x: Int) {
        _windowX = x
    }
    
    func setWindowY(y: Int) {
        _windowY = y
    }
    
    func isMessageEnded() -> Bool {
        return _isMessageEnded
    }
}