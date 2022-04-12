

import UIKit
import Firebase

class LoginVIewController: UIViewController {
    
    //delegateのインスタンス
    var searchDelegate: SearchDelegate!

    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
                
    }
    
    
    // ログインボタンをタップしたときに呼ばれるメソッド
    @IBAction func handleLoginButton(_ sender: Any) {
        
        if let address = mailAddressTextField.text, let password = passwordTextField.text {

            // アドレスとパスワード名のいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty {
                return
            }

            Auth.auth().signIn(withEmail: address, password: password) { authResult, error in
                if let error = error {
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    return
                }
                print("DEBUG_PRINT: ログインに成功しました。")
                
                //delegateする
                self.searchDelegate?.searchDelegate()
                
                //モーダルを閉じる
                self.dismiss(animated: true, completion: nil)
            
            }
            
        }
        
        
    }
    
    
    
    

        
    
    
    
    
    
    
    
}
