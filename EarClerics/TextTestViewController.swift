//
//  TextTestViewController.swift
//  EarClerics
//
//  Created by hideki on 2014/11/16.
//  Copyright (c) 2014年 Tsubaki. All rights reserved.
//

import Foundation
import UIKit

class TextTestViewController: UIViewController {
    
    let _sampleTexts = [
        "ツアーファイナル準決勝、錦織圭の世界ランキング1位ノバク・ジョコビッチ（セルビア）への挑戦は、試合時間1時間27分、1－6、6－3、0－6のスコアで決着した。",
        "過去の対戦成績は2勝2敗の五分。全米での鮮やかな勝利も記憶に新しかっただけに、力負けに落胆した向きもあっただろう。",
        "確かに、トップとの力の差はあった。しかし、それ以上にクリアに見えてきたのは、錦織の可能性だった。"
    ]
    
    var _charLabels = [UILabel]()
    
    var _msgIndex = 0
    
    var _currentText = ""
    
    //var _isMessageEnded = true
    
    var _chars = [Character]()
    
    var _twm = TextWindowManager()

    
    @IBAction func _showTextButtonClicked(sender: AnyObject) {
        if _twm._isMessageEnded {
            showNextMessage()
        }
    }
    
    func showNextMessage() {

        _currentText = _sampleTexts[_msgIndex]
        
        //showTextWithFade(_charLabels, text: _currentText)
        _twm.showTextWithFade(_charLabels, text: _currentText)

        _msgIndex++
        if _sampleTexts.count <= _msgIndex {
            _msgIndex = 0
        }
    }

    
    //===========================================================
    // UI
    //===========================================================
    
    override func viewDidLoad() {
        
        // ラベルの配列を作成
        _twm = TextWindowManager()
        _twm.setWindowX(30)
        _twm.setWindowY(200)
        
        _charLabels = _twm.makeCharLabels()
        
        for label in _charLabels {
            self.view.addSubview(label)
        }
    }
    
    
}
