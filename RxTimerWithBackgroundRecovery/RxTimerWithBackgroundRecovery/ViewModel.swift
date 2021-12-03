//
//  ViewModel.swift
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

import Foundation
import SwiftDate
import RxSwift
import RxCocoa
import NSObject_Rx
import RxSwiftExt
import RxOptional
import RxAppState

/// 倒计时时间
let COUNTDOWN_SECONDS = 60

public enum MessageStyle {
    case error
    case success
    case warning
}

public class ViewModel: NSObject {
    
    /// 处理切后台
    var isCountdown: Bool = false
    var offsetSecond: Int = 0
    var inBackgroundDate: Date?
    var backToForcegroundDate: Date?
}

public extension ViewModel {
    
    func transform(input: Input) -> Output {
        
        let messageSubject = PublishSubject<(MessageStyle, String)>()
        
        let messageTextDriver: Driver<String> = messageSubject.map{ $0.1 }.asDriver(onErrorJustReturn: "")
        let messageTextColorDriver: Driver<UIColor> = messageSubject.map{
            switch $0.0 {
            case .error:    return UIColor.red
            case .success:  return UIColor.green
            case .warning:  return UIColor.orange
            }
        }
        .asDriver(onErrorJustReturn: UIColor.orange)
        
        /// 短信验证码按钮
        let getCodeTextSubject: PublishSubject<String> = PublishSubject()
        let getCodeTextDriver: Driver<String> = getCodeTextSubject.asDriver(onErrorJustReturn: "")
        let getCodeSubTextDriver: Driver<String> = getCodeTextDriver.map{ $0 == "获取验证码" ? "" : "请稍后" }
        let getCodeEnabledDriver: Driver<Bool> = getCodeTextDriver.map{ $0 == "获取验证码" }
        let getCodeBGColorDriver: Driver<UIColor> = getCodeTextDriver.map{ $0 == "获取验证码" ? UIColor.orange : UIColor.lightGray }
        
        let timer: Observable<Int> = input.smsTrigger
            .asObservable()
            .flatMapLatest(mockRequestSMS)
            .do(onNext: {
                let clientMsg = $0 ? "短信发送成功" : "短信发送失败"
                messageSubject.onNext(($0 ? .success : .error, clientMsg))
            })
            .map{ $0 } // 这里用来做一些前置任务, 满足的情况下继续
            .filter{ $0 }
            .flatMapLatest({ _ in
                Observable<Int>.interval(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
                    .scan(COUNTDOWN_SECONDS, accumulator: { [weak self] (acc, current) in
                        print("Timer -> acc: \(acc) current: \(current) offset: \(self?.offsetSecond ?? 0)")
                        guard let offset = self?.offsetSecond, offset > 0 else { return acc - 1 }
                        let inBackground = offset
                        self?.offsetSecond = 0
                        guard offset < 60 else { return acc - acc }
                        return acc - 1 - inBackground
                    })
                    .take(while: { $0 >= 0 })
                    .startWith(COUNTDOWN_SECONDS)
            })
            .share()
            .do(onNext: { [weak self] _ in
                self?.isCountdown = true
            }, onCompleted: { [weak self] in
                self?.isCountdown = false
            })
        
        /// 倒计时按钮按钮展示文字
        timer.map{ $0 != 0 ? "\($0)S 重新发送" : "获取验证码" }.bind(to: getCodeTextSubject).disposed(by: rx.disposeBag)
        
        /// Fix: Timer切后台
        UIApplication.shared.rx.applicationDidEnterBackground
            .subscribe(with: self, onNext: { (owner, appState) in
                owner.offsetSecond = 0
                owner.inBackgroundDate = Date()
                print("applicationDidEnterBackground: \(String(describing: owner.inBackgroundDate))")
            })
            .disposed(by: rx.disposeBag)
        
        UIApplication.shared.rx.applicationWillEnterForeground
            .subscribe(with: self, onNext: { (owner, appState) in
                
                guard owner.isCountdown == true else { return }
                owner.backToForcegroundDate = Date()
                print("applicationWillEnterForeground: \(String(describing: owner.backToForcegroundDate))")
                guard let inFroceground = owner.backToForcegroundDate, let inBackground = owner.inBackgroundDate else {
                    owner.offsetSecond = 0
                    return
                }
                let second = inBackground.getInterval(toDate: inFroceground, component: .second)
                print("前后台切换中间相差时间: \(second)")
                owner.offsetSecond = Int(second)
            })
            .disposed(by: rx.disposeBag)
        
        
        return Output(
            getCodeTextDriver: getCodeTextDriver,
            getCodeSubTextDriver: getCodeSubTextDriver,
            getCodeEnabledDriver: getCodeEnabledDriver,
            getCodeBGColorDriver: getCodeBGColorDriver,
            messageTextDriver: messageTextDriver,
            messageTextColorDriver: messageTextColorDriver
        )
    }
}

public extension ViewModel {
    
    struct Input {
        let smsTrigger: Signal<Void>
    }
    struct Output {
        let getCodeTextDriver: Driver<String>
        let getCodeSubTextDriver: Driver<String>
        let getCodeEnabledDriver: Driver<Bool>
        let getCodeBGColorDriver: Driver<UIColor>
        let messageTextDriver: Driver<String>
        let messageTextColorDriver: Driver<UIColor>
    }
}


extension ViewModel {
    
    /// 模拟获取短信验证码请求
    fileprivate func mockRequestSMS() -> Single<Bool> {
        Single.just(true)
    }
}
