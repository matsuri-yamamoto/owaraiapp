//
//  CreateNewViewController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/03/29.
//

import UIKit
import Firebase

class CreateNewViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // アカウント作成ボタンをタップしたときに呼ばれるメソッド
    @IBAction func handleCreateAccountButton(_ sender: Any) {
        
        
        if let address = mailAddressTextField.text, let password = passwordTextField.text, let userName = userNameTextField.text {

            // アドレスとパスワードと表示名のいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty || userName.isEmpty {
                print("DEBUG_PRINT: 何かが空文字です。")
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
                
                //userデータの作成・保存
                //保存場所の定義
                let deleteDateTime :String? = nil
            
                let userRef = Firestore.firestore().collection("user").document()
            
                //Firestoreにデータを保存
                let userDic = [
                    "username": userName,
                    "mailaddress": address,
                    "password": password,
                    "create_datetime": FieldValue.serverTimestamp(),
                    "update_datetime": FieldValue.serverTimestamp(),
                    "delete_flag": false,
                    "delete_datetime": deleteDateTime,
                ] as [String : Any]
                userRef.setData(userDic)
                
                self.performSegue(withIdentifier: "toSearch", sender: nil)
                }
            }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
