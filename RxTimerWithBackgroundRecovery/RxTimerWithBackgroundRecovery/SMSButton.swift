//
//  SMSButton.swift
//  RxTimerWithBackgroundRecovery
//
//  Created by EZen on 2021/12/3.
//

import UIKit

class SMSButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func _setupUI() {
        layer.cornerRadius = 5
        
        if #available(iOS 15.0, *) {
            print(">= iOS 15.0")
            
            var config = UIButton.Configuration.filled()
            
            config.title = "获取验证码"
            config.subtitle = ""
            config.titleAlignment = .trailing
            config.titlePadding = 4
            config.imagePadding = 5
            config.baseBackgroundColor = .clear
            config.background.backgroundColor = .orange
            config.background.strokeColor = .purple
            config.background.strokeWidth = 2
            config.image = UIImage(named: "login_code")
            config.imagePlacement = .trailing
            
            configuration = config
            //titleLabel?.font = UIFont.systemFont(ofSize: 10)
            subtitleLabel?.font = UIFont.systemFont(ofSize: 8)
            subtitleLabel?.textColor = .orange
            subtitleLabel?.text = ""
        }
        else {
            print("< iOS 15.0")
            
            titleLabel?.font = UIFont.systemFont(ofSize: 12)
            setTitle("获取验证码", for: .normal)
            setImage(UIImage(named: "login_code")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)
            setTitleColor(.white, for: .normal)
            setTitleColor(.blue, for: .highlighted)
            setTitleColor(.red, for: .disabled)
            backgroundColor = .orange
            layer.cornerCurve = .circular
            sizeToFit()
        }
    }
    
    @available(iOS, introduced: 15.0)
    override func updateConfiguration() {
        
        guard var config = configuration else { return }
        
        switch self.state {
        case .normal:
            config.background.backgroundColor = .orange
            config.background.strokeColor = .purple
            config.background.strokeWidth = 2
            config.baseForegroundColor = .white
            config.showsActivityIndicator = false
        case [.highlighted]:
            config.background.backgroundColor = .orange.withAlphaComponent(0.2)
            config.background.strokeColor = .purple
            config.background.strokeWidth = 2
            config.baseForegroundColor = .lightGray
            config.showsActivityIndicator = false
        case .disabled:
            config.background.backgroundColor = .lightGray.withAlphaComponent(0.5)
            config.background.strokeColor = .black
            config.background.strokeWidth = 2
            config.baseForegroundColor = .lightGray
            config.showsActivityIndicator = true
        default:
            config.background.backgroundColor = .orange
            config.background.strokeColor = .purple
            config.background.strokeWidth = 2
            config.baseForegroundColor = .lightGray
            config.showsActivityIndicator = false
        }
        
        configuration = config
    }
}
