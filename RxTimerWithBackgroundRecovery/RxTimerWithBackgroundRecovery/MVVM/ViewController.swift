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
import RxSwift
import RxCocoa
import NSObject_Rx

class ViewController: UIViewController {
    
    let viewModel = ViewModel()
    
    private lazy var imageView = UIImageView()
        .then{
            $0.contentMode = .scaleAspectFit
            $0.image = UIImage(named: "ios_button_new_feature.JPG")
        }
    
    private lazy var messageLabel = UILabel()
        .then{
            $0.textAlignment = .center
            $0.font = UIFont.systemFont(ofSize: 15)
            $0.textColor = .green
            $0.text = ""
        }
    
    
    private lazy var smsButton = SMSButton()
    
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
        
        if #available(iOS 15.0, *) {
            output.getCodeTextDriver.drive(smsButton.rx.configurationTitle).disposed(by: rx.disposeBag)
            output.getCodeSubTextDriver.drive(smsButton.rx.configurationSubTitle).disposed(by: rx.disposeBag)
        }
        else {
            output.getCodeTextDriver.drive(smsButton.rx.title()).disposed(by: rx.disposeBag)
            output.getCodeBGColorDriver.drive(smsButton.rx.backgroundColor).disposed(by: rx.disposeBag)
        }
        output.getCodeTextDriver.drive(smsButton.rx.title()).disposed(by: rx.disposeBag)
        output.getCodeBGColorDriver.drive(smsButton.rx.backgroundColor).disposed(by: rx.disposeBag)
        output.getCodeEnabledDriver.drive(smsButton.rx.isEnabled).disposed(by: rx.disposeBag)
        output.messageTextDriver.drive(messageLabel.rx.text).disposed(by: rx.disposeBag)
        output.messageTextColorDriver.drive(messageLabel.rx.textColor).disposed(by: rx.disposeBag)
        
    }
}

extension ViewController {
    
    fileprivate func setupUI() {
        
        view.addSubview(imageView)
        view.addSubview(messageLabel)
        view.addSubview(smsButton)
        
        imageView.snp.makeConstraints {
            $0.left.top.right.equalToSuperview()
            $0.bottom.equalTo(messageLabel.snp.top).offset(-10)
        }
        
        messageLabel.snp.makeConstraints {
            $0.left.centerY.right.equalToSuperview()
            $0.height.equalTo(40)
        }
        smsButton.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
            if #unavailable(iOS 15.0) {
                $0.size.equalTo(CGSize(width: 120, height: 44))
            }
        }
    }
}

