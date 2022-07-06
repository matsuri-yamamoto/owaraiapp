//
//  CreateNewViewController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/03/29.
//

import UIKit
import Firebase
import FirebaseFirestore


class CreateNewViewController: UIViewController {
  
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var checkBox: UIButton!
    @IBOutlet weak var termButton: UIButton!
    @IBOutlet weak var ppButton: UIButton!
    

    var checked = false
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.isHidden = false
        
        //エラーメッセージをデフォルトでは表示させない
        errorLabel.text = nil
        
        //チェックボックスの枠の色をグレーにする
        checkBox.layer.borderWidth = 2
        checkBox.layer.borderColor = UIColor.gray.cgColor
        checkBox.addTarget(self,
                         action: #selector(didChecked),
                         for: .touchUpInside)

        if #available(iOS 15.0, *) {
            termButton.configuration = nil
            ppButton.configuration = nil

         }
        termButton.titleLabel?.font = UIFont(name: "ArialHebrew-Bold", size: 10)
        ppButton.titleLabel?.font = UIFont(name: "ArialHebrew-Bold", size: 10)

        
    }
    


    @objc private func didChecked(){
        switch checked {
                case false:
                    checkBox.setImage(UIImage(systemName: "checkmark"), for: .normal)
                    checked = true
                case true:
                    let image = UIImage(contentsOfFile: "")
            checkBox.setImage(image, for: .normal)
                    checked = false
                    print("checked:\(checked)")
            
                }
    }
    
    // アカウント作成ボタンをタップしたときに呼ばれるメソッド
    @IBAction func handleCreateAccountButton(_ sender: Any) {
        
        if checked == false {
            errorLabel.text = "利用規約とプライバシーポリシーをご確認ください"
            return
        }
        else if let nickName = nickNameTextField.text, let address = mailAddressTextField.text, let password = passwordTextField.text, let userName = userNameTextField.text {

            // アドレスとパスワードと表示名のいずれかでも入力されていない時は何もしない
            if  nickName.isEmpty || address.isEmpty || password.isEmpty || userName.isEmpty {
                print("DEBUG_PRINT: 何かが空文字です。")
                errorLabel.text = "入力内容をご確認ください"
                return
            }
            
            // アドレスとパスワードでユーザー作成。ユーザー作成に成功すると、自動的にログインする
            Auth.auth().createUser(withEmail: address, password: password) { authResult, error in
                if let error = error {
                    // エラーがあったら原因をprintして、returnすることで以降の処理を実行せずに処理を終了する
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    return
                }
                print("DEBUG_PRINT: ユーザー作成に成功しました。")

                //createProfileChangeRequestでユーザー名を登録する
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = userName
                changeRequest?.commitChanges { error in
                    if let error = error{
                        // エラーがあったら原因をprintして、returnすることで以降の処理を実行せずに処理を終了する
                        print("DEBUG_PRINT: " + error.localizedDescription)
                        return
                    }
                    print("DEBUG_PRINT: ユーザー名登録に成功しました。")
                }

                //ニックネームを保存する
                
                print("currentUser\(Auth.auth().currentUser?.uid)")
                            
                
                let deleteDateTime :String? = nil

                let nickNameRef = Firestore.firestore().collection("user_detail").document()
                let nickNameDic = [
                    "user_id": Auth.auth().currentUser?.uid,
                    "nickname": self.nickNameTextField.text,
                    "create_datetime": FieldValue.serverTimestamp(),
                    "update_datetime": FieldValue.serverTimestamp(),
                    "delete_flag": false,
                    "delete_datetime": deleteDateTime,
                ] as [String : Any]
                
                print("nickNameDic\(nickNameDic)")
                
                nickNameRef.setData(nickNameDic)
                

                self.performSegue(withIdentifier: "searchSegue", sender: nil)

            }
        }
    }
                            
    
    //viewをタップしたときにキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    

    
}
