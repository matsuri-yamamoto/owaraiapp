//
//  StartViewController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/03/29.
//
import UIKit
import OAuthSwift
import Firebase
import FirebaseAuth
import KeychainAccess
import FirebaseFirestore

class StartViewController: UIViewController {
    
    private var provider: OAuthProvider?
                
 
    override func viewDidAppear(_ animated: Bool) {
        //pvログ
        AnalyticsUtil.sendScreenName(ScreenEvent(screenName: .startVC))
    }
    
    @IBAction func tappedLoginButton(_ sender: Any) {
        
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! LoginViewController
        self.navigationController?.pushViewController(loginVC, animated: true)
        
        //ログ
        AnalyticsUtil.sendAction(ActionEvent(screenName: .startVC,
                                                     actionType: .tap,
                                             actionLabel: .template(ActionLabelTemplate.MailLoginPassTap)))
        
    }
    
    @IBAction func tappedCreateNewButton(_ sender: Any) {
        
        let createNewVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateNew") as! CreateNewViewController
        self.navigationController?.pushViewController(createNewVC, animated: true)
        
        //ログ
        AnalyticsUtil.sendAction(ActionEvent(screenName: .startVC,
                                                     actionType: .tap,
                                             actionLabel: .template(ActionLabelTemplate.MailNewPassTap)))
    }
    
    
    @IBAction func clickButton(_ sender: UIButton) {
        
        provider = OAuthProvider(providerID: "twitter.com")
              provider?.getCredentialWith(nil) { credential, error in
                  guard let credential = credential, error == nil else {
                      
                      //エラーログ
                      AnalyticsUtil.sendAction(ActionEvent(screenName: .startVC,
                                                                   actionType: .error,
                                                           actionLabel: .template(ActionLabelTemplate.twitterLoginError)))
                      return
                  }

                  Auth.auth().signIn(with: credential) { result, error in
                      guard error == nil else {
                          //エラーログ
                          AnalyticsUtil.sendAction(ActionEvent(screenName: .startVC,
                                                                       actionType: .error,
                                                               actionLabel: .template(ActionLabelTemplate.twitterLoginError)))

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
                              //エラーログ
                              AnalyticsUtil.sendAction(ActionEvent(screenName: .startVC,
                                                                           actionType: .error,
                                                                   actionLabel: .template(ActionLabelTemplate.mailLoginError)))
                              
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
                                  AnalyticsUtil.sendAction(ActionEvent(screenName: .startVC,
                                                                               actionType: .tap,
                                                                       actionLabel: .template(ActionLabelTemplate.twitterLoginPassTap)))

                              } else {
                                  
                                  let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "Tabbar") as! TabBarController
                                  self.navigationController?.pushViewController(tabBarVC, animated: true)
                                  
                                  //ログ
                                  AnalyticsUtil.sendAction(ActionEvent(screenName: .startVC,
                                                                               actionType: .tap,
                                                                       actionLabel: .template(ActionLabelTemplate.twitterLoginPassTap)))

                                  
                              }
                          }
                      }
                  }
              }
    }
    
}

