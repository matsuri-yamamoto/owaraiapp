//
//  StartViewController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/03/29.
//

import UIKit
import OAuthSwift


struct Const {
    static let consumerKey = "jQfkMjkKOr96wuPIsLpHMntXc"
    static let consumerSecret = "LU3rME3W1CYIQvUngni8KE6tcfVA21NR7NIqFNh882Lq96gHuM"
}


class StartViewController: UIViewController {
    
    var oauthswift: OAuthSwift?
            
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

    }
    
    
    @IBAction func clickButton(_ sender: UIButton) {
        doOAuthTwitter()
    }

    /// OAuthログイン処理
    func doOAuthTwitter(){

        let oauthswift = OAuth1Swift(
            consumerKey: Const.consumerKey,
            consumerSecret: Const.consumerSecret,
            requestTokenUrl: "https://api.twitter.com/oauth/request_token",
            authorizeUrl:    "https://api.twitter.com/oauth/authorize",
            accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
        )
        self.oauthswift = oauthswift
        oauthswift.authorizeURLHandler = getURLHandler()

        // コールバック処理
        oauthswift.authorize(withCallbackURL: URL(string: "TwitterLoginSampleOAuth://")!,
                             completionHandler:
            { result in
                switch result {
                case .success(let (credential, _, _)):
                    print(credential.oauthToken)
                    print(credential.oauthTokenSecret)
                    self.showAlert(credential: credential)
                    print("success")
                case .failure(let error):
                    print(error.localizedDescription)
                    print("failure")
                }
        }
        )
    }

    /// ログイン画面起動に必要な処理
    ///
    /// - Returns: OAuthSwiftURLHandlerType
    func getURLHandler() -> OAuthSwiftURLHandlerType {
        if #available(iOS 9.0, *) {
            let handler = SafariURLHandler(viewController: self, oauthSwift: self.oauthswift!)
            handler.presentCompletion = {
                print("Safari presented")
            }
            handler.dismissCompletion = {
                print("Safari dismissed")
            }
            return handler
        }
        return OAuthSwiftOpenURLExternally.sharedInstance
    }

    /// アラート表示
    ///
    /// - Parameter credential: OAuthSwiftCredential
    func showAlert(credential: OAuthSwiftCredential) {
        var message = "oauth_token:\(credential.oauthToken)"
        if !credential.oauthTokenSecret.isEmpty {
            message += "\n\noauth_token_secret:\(credential.oauthTokenSecret)"
        }
        let alert = UIAlertController(title: "ログイン",
                                      message: message,
            preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
