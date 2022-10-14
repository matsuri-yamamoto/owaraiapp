//
//  OnboardingCreateNewViewController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/10/13.
//

import UIKit
import FirebaseFirestore
import Firebase


class OnboardingCreateNewViewController: UIViewController {
    
    //前画面から渡されるレビューの値
    var comedianId :String = ""
    var comedianName :String = ""
    var comment :String = ""
    var score :Double = 0
    var tag1: String = ""
    var tag2: String = ""
    var tag3: String = ""
    var tag4: String = ""
    var tag5: String = ""
    
    let deleteDateTime :String? = nil
    
    
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var displayIdTextField: UITextField!
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    let currentUser = Auth.auth().currentUser
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //エラーメッセージをデフォルトでは表示させない
        errorLabel.text = ""
        
        //ボタンの角を丸くする
        self.saveButton.layer.cornerRadius = 9
        self.saveButton.clipsToBounds = true
        
        
        
    }
    
    
    @IBAction func tappedSaveButton(_ sender: Any) {
        
        //アカウント作成
        if let userName = userNameTextField.text, let address = mailAddressTextField.text, let password = passwordTextField.text, let displayId = displayIdTextField.text {
            
            // いずれかでも入力されていない時は何もしない
            if  userName.isEmpty || address.isEmpty || password.isEmpty || displayId.isEmpty {
                print("DEBUG_PRINT: 何かが空文字です。")
                errorLabel.text = "すべての項目が入力されているかご確認ください！"
                return
            }
            
            // アドレスとパスワードでユーザー作成。ユーザー作成に成功すると、自動的にログインする
            Auth.auth().createUser(withEmail: address, password: password) { authResult, error in
                if let error = error {
                    // エラーがあったら原因をprintして、returnすることで以降の処理を実行せずに処理を終了する
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    //エラーログ
                    AnalyticsUtil.sendAction(ActionEvent(screenName: .createNewVC,
                                                         actionType: .error,
                                                         actionLabel: .template(ActionLabelTemplate.mailNewError)))
                    return
                }
                
                //ユーザー登録成功
                print("DEBUG_PRINT: ユーザー作成に成功しました。")
                
                //createProfileChangeRequestでユーザー名を登録する
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = userName
                changeRequest?.commitChanges { error in
                    if let error = error{
                        // エラーがあったら原因をprintして、returnすることで以降の処理を実行せずに処理を終了する
                        print("faild:ユーザーネーム登録 " + error.localizedDescription)
                        //エラーログ
                        AnalyticsUtil.sendAction(ActionEvent(screenName: .createNewVC,
                                                             actionType: .error,
                                                             actionLabel: .template(ActionLabelTemplate.mailNewNameError)))
                        
                        return
                    }
                    //ユーザー名登録成功
                    print("successed:ユーザーネーム登録")
                    //user_detailにdisplayIdを作成する
                    let userNameRef = self.db.collection("user_detail").document()
                    let userNameDic = [
                        "user_id": Auth.auth().currentUser?.uid,
                        "display_id": self.displayIdTextField.text!,
                        "create_datetime": FieldValue.serverTimestamp(),
                        "update_datetime": FieldValue.serverTimestamp(),
                        "delete_flag": false,
                        "delete_datetime": self.deleteDateTime,
                    ] as [String : Any]
                    
                    print("userNameDic\(userNameDic)")
                    
                    userNameRef.setData(userNameDic)
                    
                    //レビューを保存する
                    let reviewRef = self.db.collection("review").document()
                    let reviewDic = [
                        "user_id": Auth.auth().currentUser?.uid,
                        "display_id": self.displayIdTextField.text!,
                        "user_name": Auth.auth().currentUser?.displayName,
                        "comedian_id": self.comedianId,
                        "comedian_display_name": self.comedianName,
                        "score": self.score,
                        "comment": self.comment,
                        "tag_1": self.tag1,
                        "tag_2": self.tag2,
                        "tag_3": self.tag3,
                        "tag_4": self.tag4,
                        "tag_5": self.tag5,
                        "relational_comedian_listname": "",
                        "private_flag": false,
                        "create_datetime": FieldValue.serverTimestamp(),
                        "update_datetime": FieldValue.serverTimestamp(),
                        "delete_flag": false,
                        "delete_datetime": self.deleteDateTime as Any,
                    ] as [String : Any]
                    
                    print("reviewDic:\(reviewDic)")
                    reviewRef.setData(reviewDic)
                    
                    //user_detail作成が完了しているか確かめる
                    self.db.collection("user_detail").whereField("user_id", isEqualTo: self.currentUser?.uid).getDocuments() { [self] (querySnapshot, err) in
                        
                        if let err = err {
                            print("Error getting documents: \(err)")
                            return
                            
                        } else {
                            
                            //user_detail作成が完了していない場合は1秒次の処理を待つ
                            if querySnapshot?.documents.count == 0 {
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    
                                    self.checkReview()
                                
                                }

                            } else {
                                //user_detail作成が完了している場合はすぐに次の処理を行う
                                self.checkReview()
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    func checkReview() {
        
        //review作成が完了しているか確かめる
        self.db.collection("review").whereField("user_id", isEqualTo: self.currentUser?.uid).whereField("comedian_id", isEqualTo: self.comedianId).getDocuments() { [self] (querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                
                //review作成が完了している場合はすぐに画面遷移する

                if (querySnapshot?.documents.count)! > 0 {
                    
                    let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "Tabbar") as! TabBarController
                    tabBarVC.afterOnboardFlag = "true"
                    tabBarVC.displayId = self.displayIdTextField.text!
                    tabBarVC.comedianId = self.comedianId
                    tabBarVC.comedianName = self.comedianName
                    tabBarVC.score = self.score
                    tabBarVC.comment = self.comment
                    
                    self.navigationController?.pushViewController(tabBarVC, animated: true)
                    
                    
                } else {
                    //review作成が完了していない場合は1秒次の処理を待つ
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        
                        let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "Tabbar") as! TabBarController
                        tabBarVC.afterOnboardFlag = "true"
                        tabBarVC.displayId = self.displayIdTextField.text!
                        tabBarVC.comedianId = self.comedianId
                        tabBarVC.comedianName = self.comedianName
                        tabBarVC.score = self.score
                        tabBarVC.comment = self.comment
                        
                        self.navigationController?.pushViewController(tabBarVC, animated: true)

            
                    }
                }

            }
        }
        
    }
    
    
    
    
    
    //viewをタップしたときにキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    
    
}
