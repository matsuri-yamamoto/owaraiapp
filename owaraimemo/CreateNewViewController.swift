
import UIKit
import Firebase
import FirebaseFirestore


class CreateNewViewController: UIViewController {
  
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var displayIdTextField: UITextField!
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
//    @IBOutlet weak var passwordMaskingChangeButton: UIButton!
    
    
    @IBOutlet weak var saveButton: UIButton!
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.title = "ユーザー登録"
        
        //エラーメッセージをデフォルトでは表示させない
        errorLabel.text = nil
        
        userNameTextField.layer.borderColor = UIColor.systemOrange.cgColor
        userNameTextField.layer.borderWidth = 0.5
        
        displayIdTextField.layer.borderColor = UIColor.systemOrange.cgColor
        displayIdTextField.layer.borderWidth = 0.5
        
        mailAddressTextField.layer.borderColor = UIColor.systemOrange.cgColor
        mailAddressTextField.layer.borderWidth = 0.5
        
        passwordTextField.layer.borderColor = UIColor.systemOrange.cgColor
        passwordTextField.layer.borderWidth = 0.5
        
        //ボタンの角を丸くする
        self.saveButton.layer.cornerRadius = 9
        self.saveButton.clipsToBounds = true

        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //pvログ
        AnalyticsUtil.sendScreenName(ScreenEvent(screenName: .createNewVC))

    }
    
    
//    @IBAction func passwordMaskingChangeTapped(_ sender: Any) {
//
//
//        if self.passwordTextField.isSecureTextEntry == true {
//
//            self.passwordTextField.isSecureTextEntry = false
//            self.passwordMaskingChangeButton.imageView?.image = UIImage(systemName: "eye.slash")
//            self.view.addSubview(passwordMaskingChangeButton)
//
//        }
//
//        if self.passwordTextField.isSecureTextEntry == false {
//
//            self.passwordTextField.isSecureTextEntry = true
//            self.passwordMaskingChangeButton.imageView?.image = UIImage(systemName: "eye")
//            self.view.addSubview(passwordMaskingChangeButton)
//
//
//        }
//
//    }
    
    // アカウント作成ボタンをタップしたときに呼ばれるメソッド
    @IBAction func handleCreateAccountButton(_ sender: Any) {
 
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
                    print("successed:ユーザーネーム登録")
                }

                
                //user_detailを作成する
                Firestore.firestore().collection("user_detail").whereField("user_id", isEqualTo: Auth.auth().currentUser?.uid).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                        //エラーログ
                        AnalyticsUtil.sendAction(ActionEvent(screenName: .createNewVC,
                                                                     actionType: .error,
                                                             actionLabel: .template(ActionLabelTemplate.mailNewIdError)))
                        
                    } else {
                        
                        print("querySnapshot!.documents.count:\(querySnapshot!.documents.count)")
                        
                        if querySnapshot!.documents.count == 0 {
                            
                            let deleteDateTime :String? = nil

                            let userNameRef = Firestore.firestore().collection("user_detail").document()
                            let userNameDic = [
                                "user_id": Auth.auth().currentUser?.uid,
                                "display_id": self.displayIdTextField.text,
                                "create_datetime": FieldValue.serverTimestamp(),
                                "update_datetime": FieldValue.serverTimestamp(),
                                "delete_flag": false,
                                "delete_datetime": deleteDateTime,
                            ] as [String : Any]
                            
                            print("userNameDic\(userNameDic)")
                            
                            userNameRef.setData(userNameDic)
                            self.performSegue(withIdentifier: "searchSegue", sender: nil)
                            
                            //ログ
                            AnalyticsUtil.sendAction(ActionEvent(screenName: .createNewVC,
                                                                         actionType: .tap,
                                                                 actionLabel: .template(ActionLabelTemplate.mailNewTap)))

                            
                        } else {
                            
                            self.performSegue(withIdentifier: "searchSegue", sender: nil)
                            
                            //ログ
                            AnalyticsUtil.sendAction(ActionEvent(screenName: .createNewVC,
                                                                         actionType: .tap,
                                                                 actionLabel: .template(ActionLabelTemplate.mailNewTap)))



                        }
                        
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
