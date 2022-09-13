

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = false
        self.title = "メールアドレスでログイン"
        
        mailAddressTextField.layer.borderColor = UIColor.systemOrange.cgColor
        mailAddressTextField.layer.borderWidth = 0.5
        
        passwordTextField.layer.borderColor = UIColor.systemOrange.cgColor
        passwordTextField.layer.borderWidth = 0.5
        
        //ボタンの角を丸くする
        self.loginButton.layer.cornerRadius = 9
        self.loginButton.clipsToBounds = true
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //pvログ
        AnalyticsUtil.sendScreenName(ScreenEvent(screenName: .loginVC))
        
    }
    
    
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    
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
                self.performSegue(withIdentifier: "searchSegue", sender: nil)
                
                //ログ
                AnalyticsUtil.sendAction(ActionEvent(screenName: .loginVC,
                                                     actionType: .tap,
                                                     actionLabel: .template(ActionLabelTemplate.mailLoginTap)))
                
                
            }
        }
    }
    //viewをタップしたときにキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
