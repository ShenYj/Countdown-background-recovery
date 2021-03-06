//
//  UIButton+RxConfiguration.swift
//  RxTimerWithBackgroundRecovery
//
//  Created by ShenYj on 2021/12/03.
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

import RxSwift

///
///  简单的扩展, 更好的结合 RxSwift 来进行绑定
///
@available(iOS, introduced: 15.0, message: "extension for UIButton.Configuration")
extension Reactive where Base: UIButton {
    
    /// Reactive wrapper for `configuration?.subtitle`
    public var configurationSubTitle: Binder<String?> {
        Binder(self.base) { (owner, subTitle) in
            owner.configuration?.subtitle = subTitle
        }
    }
    
    /// Reactive wrapper for `configuration?.title`
    public var configurationTitle: Binder<String?> {
        Binder(self.base) { (owner, title) in
            owner.configuration?.title = title
        }
    }
    
    /// Reactive wrapper for `configuration?.image`
    public var configurationImage: Binder<UIImage?> {
        Binder(self.base) { (owner, image) in
            owner.configuration?.image = image
        }
    }
}
