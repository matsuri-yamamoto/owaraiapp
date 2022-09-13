

import UIKit
import Firebase

class SettingViewController: UIViewController {
    
    //ナビゲーションバーのボタンの変数
    var backButtonItem: UIBarButtonItem!
    
    let currentUser = Auth.auth().currentUser
    let db = Firestore.firestore()
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        //ナビゲーションバーのボタン設置
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(backButtonPressed))
        self.tabBarController!.tabBar.isHidden = true
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //pvログ
        AnalyticsUtil.sendScreenName(ScreenEvent(screenName: .settingVC))
    }
    
    @objc func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func aboutTsubologButton(_ sender: Any) {
        let aboutTsuboVC = storyboard?.instantiateViewController(withIdentifier: "AboutTsubolog") as! AboutTsubologViewController
        self.navigationController?.pushViewController(aboutTsuboVC, animated: true)
        
    }
    
    
    
    @IBAction func logoutButton(_ sender: Any) {
        // ログアウトする
        try! Auth.auth().signOut()
        
        let startVC = self.storyboard?.instantiateViewController(identifier: "Start") as! StartViewController
        self.navigationController!.navigationBar.isHidden = true
        self.navigationController?.pushViewController(startVC, animated: true)
        self.tabBarController!.tabBar.isHidden = true
        
        
    }
    
    @IBAction func termsButton(_ sender: Any) {
        
        let termVC = storyboard?.instantiateViewController(withIdentifier: "Term") as! TermViewController
        self.navigationController?.pushViewController(termVC, animated: true)
        
    }
    
    @IBAction func ppButton(_ sender: Any) {
        
        let ppVC = storyboard?.instantiateViewController(withIdentifier: "PrivacyPolicy") as! PrivacyPolicyViewController
        self.navigationController?.pushViewController(ppVC, animated: true)
        
    }
    
    @IBAction func inquiryButton(_ sender: Any) {
        
        let inquiryVC = storyboard?.instantiateViewController(withIdentifier: "Inquiry") as! InquiryViewController
        self.navigationController?.pushViewController(inquiryVC, animated: true)
        
    }
    
    @IBAction func withdrawalButton(_ sender: Any) {
        
        //アラート生成
        //UIAlertControllerのスタイルがalert
        let alert: UIAlertController = UIAlertController(title: "退会", message:  "退会してよろしいですか？", preferredStyle:  UIAlertController.Style.alert)
        // 確定ボタンの処理
        let confirmAction: UIAlertAction = UIAlertAction(title: "確定", style: UIAlertAction.Style.default, handler:{
            // 確定ボタンが押された時の処理をクロージャ実装する
            (action: UIAlertAction!) -> Void in
            
            //紐づくuser_detailを削除
            self.db.collection("user_detail").whereField("user_id", isEqualTo: self.currentUser?.uid).getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    
                } else {
                    
                    for document in querySnapshot!.documents{
                        
                        var documentId :String
                        documentId = document.documentID
                        
                        let existUserDetailRef = self.db.collection("user_detail").document(documentId)
                        existUserDetailRef.updateData([
                            "delete_flag": true,
                            "delete_datetime": FieldValue.serverTimestamp(),
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                            }
                        }
                    }
                }
            }
            //紐づくreviewを削除
            self.db.collection("review").whereField("user_id", isEqualTo: self.currentUser?.uid).getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    
                } else {
                    
                    for document in querySnapshot!.documents{
                        
                        var documentId :String
                        documentId = document.documentID
                        
                        let existReviewRef = self.db.collection("review").document(documentId)
                        existReviewRef.updateData([
                            "delete_flag": true,
                            "delete_datetime": FieldValue.serverTimestamp(),
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                            }
                        }
                    }
                }
            }
            
            
            //紐づくstockを削除
            self.db.collection("stock").whereField("user_id", isEqualTo: self.currentUser?.uid).getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    
                } else {
                    
                    for document in querySnapshot!.documents{
                        
                        var documentId :String
                        documentId = document.documentID
                        
                        let existStockRef = self.db.collection("stock").document(documentId)
                        existStockRef.updateData([
                            "delete_flag": true,
                            "delete_datetime": FieldValue.serverTimestamp(),
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                            }
                        }
                    }
                }
            }
            
            //紐づくlike_reviewを削除
            self.db.collection("like_review").whereField("like_user_id", isEqualTo: self.currentUser?.uid).getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    
                } else {
                    
                    for document in querySnapshot!.documents{
                        
                        var documentId :String
                        documentId = document.documentID
                        
                        let existLikeReviewRef = self.db.collection("like_review").document(documentId)
                        existLikeReviewRef.updateData([
                            "delete_flag": true,
                            "delete_datetime": FieldValue.serverTimestamp(),
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                            }
                        }
                    }
                }
            }

            
            //アカウントを削除
            self.currentUser?.delete { error in
                if let error = error {
                    // An error happened.
                    print("Failed：退会")
                } else {
                    // Account deleted.
                    print("Successed：退会")
                    
                    let startVC = self.storyboard?.instantiateViewController(withIdentifier: "Start") as! StartViewController
                    
                    self.navigationController?.pushViewController(startVC, animated: true)

                    
                }
            }
            print("確定")
        })
        // キャンセルボタンの処理
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            // キャンセルボタンが押された時の処理をクロージャ実装する
            (action: UIAlertAction!) -> Void in
            //実際の処理
            print("キャンセル")
            return

        })
        
        //UIAlertControllerにキャンセルボタンと確定ボタンをActionを追加
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        //実際にAlertを表示する
        present(alert, animated: true, completion: nil)
        
    }
    
}


