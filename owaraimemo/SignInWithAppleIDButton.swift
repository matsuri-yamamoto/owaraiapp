//
//  SignInWithAppleIDButton.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/09/11.
//

import UIKit
import AuthenticationServices


@IBDesignable
class SignInWithAppleIDButton: UIButton {
    
    private var appleIDButton: ASAuthorizationAppleIDButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)

        // Create ASAuthorizationAppleIDButton
        appleIDButton = ASAuthorizationAppleIDButton(authorizationButtonType: .default, authorizationButtonStyle: .black)
        

        // Show authorizationButton
        addSubview(appleIDButton)

        // Use auto layout to make authorizationButton follow the MyAuthorizationAppleIDButton's dimension
        appleIDButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            appleIDButton.topAnchor.constraint(equalTo: self.topAnchor),
            appleIDButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            appleIDButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            appleIDButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
        appleIDButton.addTarget(self, action: #selector(appleIDButtonTapped), for: .touchUpInside)
        
    }
    
    
    @objc
    func appleIDButtonTapped(_ sender: Any) {
        sendActions(for: .touchUpInside)
    }

}
