//
//  RecommendLoginViewController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/07/11.
//

import UIKit
import OAuthSwift
import Firebase
import FirebaseAuth
import FirebaseFirestore
import KeychainAccess



class RecommendLoginViewController: UIViewController {
    
    private var provider: OAuthProvider?
    
    @IBOutlet weak var phraseLabel2: UILabel!
    @IBOutlet weak var phraseLabel3: UILabel!
    
    @IBOutlet weak var twitterLoginButton: UIButton!
    @IBOutlet weak var mailLoginButton: UIButton!
    @IBOutlet weak var mailNewButton: UIButton!
    
    var backAnotherButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.title = "ログインするとできること"
        
        self.tabBarController?.tabBar.isHidden = true
        
        let count = (self.navigationController?.viewControllers.count)! - 2
        if self.navigationController?.viewControllers[count] is MyReviewViewController {
            
            self.navigationItem.hidesBackButton = true
            backAnotherButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(backAnotherButtonTapped(_:)))
            self.navigationItem.rightBarButtonItems = [backAnotherButton]
            
        
            } else {
                
                return
                
            }
        
        self.twitterLoginButton.layer.cornerRadius = 8
        self.twitterLoginButton.clipsToBounds = true
        self.mailNewButton.layer.cornerRadius = 8
        self.mailNewButton.clipsToBounds = true
        self.mailLoginButton.layer.cornerRadius = 8
        self.mailLoginButton.clipsToBounds = true

 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //pvログ
        AnalyticsUtil.sendScreenName(ScreenEvent(screenName: .recLoginVC))

    }
    
    @IBAction func tappedTwitterButton(_ sender: Any) {
        //Twitterの件質問したら追記
        provider = OAuthProvider(providerID: "twitter.com")
              provider?.getCredentialWith(nil) { credential, error in
                  guard let credential = credential, error == nil else {
                      return
                  }

                  Auth.auth().signIn(with: credential) { result, error in
                      guard error == nil else {
                          return
                      }

                      if let credential = result?.credential as? OAuthCredential,
                          let accessToken = credential.accessToken,
                          let secret = credential.secret {

                          let keychain = Keychain(service: Bundle.main.bundleIdentifier!)
                          try? keychain.set(accessToken, key: "jQfkMjkKOr96wuPIsLpHMntXc")
                          try? keychain.set(secret, key: "LU3rME3W1CYIQvUngni8KE6tcfVA21NR7NIqFNh882Lq96gHuM")
                      }
                      
                      //resultで取得できる情報に「credential」と「additional,,」がある
                      //aditionalをprintして中身を確認する
                      print("additionalUserInfo:\(result?.additionalUserInfo)")
                      print("additionalUserInfo:\(result?.additionalUserInfo?.providerID)")
                      print("additionalUserInfo:\(result?.additionalUserInfo?.username)")
                      print("additionalUserInfo:\(result?.additionalUserInfo?.profile?["screen_name"] as! String)")
                      
                      print("twiterLoginDisplayName:\(Auth.auth().currentUser?.displayName)")

                      
                      
                      //過去にログインしたことがなかったら、user_detailを作成する
                      Firestore.firestore().collection("user_detail").whereField("user_id", isEqualTo: Auth.auth().currentUser?.uid).getDocuments() { (querySnapshot, err) in
                          if let err = err {
                              print("Error getting documents: \(err)")
                              
                          } else {
                              
                              print("querySnapshot!.documents.count:\(querySnapshot!.documents.count)")
                              
                              if querySnapshot!.documents.count == 0 {
                                  
                                  let deleteDateTime :String? = nil

                                  let userNameRef = Firestore.firestore().collection("user_detail").document()
                                  let userNameDic = [
                                      "user_id": Auth.auth().currentUser?.uid,
                                      "display_id": result?.additionalUserInfo?.profile?["screen_name"] as! String,
                                      "create_datetime": FieldValue.serverTimestamp(),
                                      "update_datetime": FieldValue.serverTimestamp(),
                                      "delete_flag": false,
                                      "delete_datetime": deleteDateTime,
                                  ] as [String : Any]
                                  
                                  print("userNameDic\(userNameDic)")
                                  
                                  userNameRef.setData(userNameDic)
                                  

                                  print("finalDisplayName:\(String(describing: Auth.auth().currentUser?.displayName))")

                                  let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "Tabbar") as! TabBarController
                                  self.navigationController?.pushViewController(tabBarVC, animated: true)
                                  
                                  //ログ
                                  AnalyticsUtil.sendAction(ActionEvent(screenName: .recLoginVC,
                                                                               actionType: .tap,
                                                                       actionLabel: .template(ActionLabelTemplate.twitterLoginPassTap)))
                                  
                              } else {
                                  
                                  let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "Tabbar") as! TabBarController
                                  self.navigationController?.pushViewController(tabBarVC, animated: true)
                                  
                                  //ログ
                                  AnalyticsUtil.sendAction(ActionEvent(screenName: .recLoginVC,
                                                                               actionType: .tap,
                                                                       actionLabel: .template(ActionLabelTemplate.twitterLoginPassTap)))
                                  
                              }
                          }
                      }
                  }
              }
        
        
        
    }
    
    
    @IBAction func tappedMailLogin(_ sender: Any) {
        

        let loginVC = storyboard?.instantiateViewController(withIdentifier: "Login") as! LoginViewController

        self.navigationController?.pushViewController(loginVC, animated: true)
        
        //ログ
        AnalyticsUtil.sendAction(ActionEvent(screenName: .recLoginVC,
                                                     actionType: .tap,
                                             actionLabel: .template(ActionLabelTemplate.MailLoginPassTap)))

        

    }

    @IBAction func tappedMailNew(_ sender: Any) {

        let mailNewVC = storyboard?.instantiateViewController(withIdentifier: "CreateNew") as! CreateNewViewController

        self.navigationController?.pushViewController(mailNewVC, animated: true)
        
        //ログ
        AnalyticsUtil.sendAction(ActionEvent(screenName: .recLoginVC,
                                                     actionType: .tap,
                                             actionLabel: .template(ActionLabelTemplate.MailNewPassTap)))

    }
    
    @objc func backAnotherButtonTapped(_ sender: UIBarButtonItem) {
        
        let tabVC = storyboard?.instantiateViewController(withIdentifier: "Tabbar") as! TabBarController

        self.navigationController?.pushViewController(tabVC, animated: true)
        
    }
    
    
    @IBAction func termsButton(_ sender: Any) {
        
        let termVC = storyboard?.instantiateViewController(withIdentifier: "Term") as! TermViewController
        self.navigationController?.pushViewController(termVC, animated: true)
        
    }
    
    @IBAction func ppButton(_ sender: Any) {
        
        let ppVC = storyboard?.instantiateViewController(withIdentifier: "PrivacyPolicy") as! PrivacyPolicyViewController
        self.navigationController?.pushViewController(ppVC, animated: true)
        
    }
    
    
}


