//
//  ViewController.swift
//  RxTimerWithBackgroundRecovery
//
//  Created by ShenYj on 2021/08/24.
//
//  Copyright (c) 2021 ShenYj <shenyanjie123@foxmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import SnapKit
import Then
import SwifterSwift
import RxSwift
import RxCocoa
import NSObject_Rx


class ViewController: UIViewController {
    
    let viewModel = ViewModel()
    
    lazy var messageLabel = UILabel()
        .then{
            $0.textAlignment = .center
            $0.font = UIFont.systemFont(ofSize: 15)
            $0.textColor = .random
            $0.text = ""
        }
    
    lazy var smsButton = UIButton()
        .then{
            $0.setTitle("获取验证码", for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.setTitleColor(UIColor.blue, for: .normal)
            $0.setTitleColor(UIColor.gray, for: .highlighted)
            $0.setTitleColor(UIColor.gray, for: .disabled)
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupUI()
        bindViewModel()
    }

}

extension ViewController {
    
    fileprivate func bindViewModel() {
        
        let smsTrigger: Signal<Void> = smsButton.rx.tap.asSignal()
        
        let input = ViewModel.Input(smsTrigger: smsTrigger)
        let output = viewModel.transform(input: input)
        
        output.getCodeTextDriver.drive(smsButton.rx.title()).disposed(by: rx.disposeBag)
        output.getCodeEnabledDriver.drive(smsButton.rx.isEnabled).disposed(by: rx.disposeBag)
        output.messageTextDriver.drive(messageLabel.rx.text).disposed(by: rx.disposeBag)
        output.messageTextColorDriver.drive(messageLabel.rx.textColor).disposed(by: rx.disposeBag)
        
    }
}

extension ViewController {
    
    fileprivate func setupUI() {
        
        view.addSubview(messageLabel)
        view.addSubview(smsButton)
        
        messageLabel.snp.makeConstraints {
            $0.left.centerY.right.equalToSuperview()
            $0.height.equalTo(40)
        }
        smsButton.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(40)
            $0.size.equalTo(CGSize(width: 120, height: 44))
            $0.centerX.equalToSuperview()
        }
    }
}

