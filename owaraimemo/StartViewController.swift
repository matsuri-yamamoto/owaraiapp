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
                
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

    }
    
    
    @IBAction func clickButton(_ sender: UIButton) {
        
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
                      
                      
                      //ユーザーネームを保存する
                      let deleteDateTime :String? = nil

                      let userNameRef = Firestore.firestore().collection("user_detail").document()
                      let userNameDic = [
                          "user_id": Auth.auth().currentUser?.uid,
                          "username": Auth.auth().currentUser?.displayName,
                          "create_datetime": FieldValue.serverTimestamp(),
                          "update_datetime": FieldValue.serverTimestamp(),
                          "delete_flag": false,
                          "delete_datetime": deleteDateTime,
                      ] as [String : Any]
                      
                      print("userNameDic\(userNameDic)")
                      
                      userNameRef.setData(userNameDic)
                      
                      print("firstDisplayName:\(String(describing: Auth.auth().currentUser?.displayName))")

                      //displayNameを上書きする
                      Auth.auth().currentUser?.createProfileChangeRequest().displayName = result?.additionalUserInfo?.profile?["screen_name"] as? String
                      
                      Auth.auth().currentUser?.createProfileChangeRequest().commitChanges() { error in
                          if error == nil {
                              print("Successed：Twitterログイン→displayNameの更新")
                              
                          } else {
                              print("Failed：Twitterログイン→displayNameの更新")

                          }
                          
                      }
                      print("finalDisplayName:\(String(describing: Auth.auth().currentUser?.displayName))")

                      
                  }
                  
              }
        
        
//        let user = Auth.auth().currentUser
//        if let user = user {
//
//            let uid = user.uid
//            let email = user.email
//            let displayName = user.displayName
//
//            let twitterUserId :String
//            twitterUserId = Result.additionalUserInfo?.username
//
//            print("uid:\(uid)")
//            print("email:\(String(describing: email))")
//            print("displayName:\(String(describing: displayName))")
//
//            print("twitterUser:\(user)")
//
//        }
        

                

        
        
        
        let tabBarVC = storyboard?.instantiateViewController(withIdentifier: "Tabbar") as! TabBarController

        self.navigationController?.pushViewController(tabBarVC, animated: true)
    }
}
        
        


