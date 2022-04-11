

import UIKit
import Firebase

class SettingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController!.navigationBar.isHidden = true

    }
        
    
    @IBAction func logoutButton(_ sender: Any) {
        // ログアウトする
        try! Auth.auth().signOut()
        
        
        // ログイン画面から戻ってきた時のためにホーム画面（index = 0）を選択している状態にしておく
//        tabBarController?.selectedIndex = 0
        
        let startVC = self.storyboard?.instantiateViewController(identifier: "Start") as! StartViewController
        self.navigationController!.navigationBar.isHidden = true
        self.navigationController?.pushViewController(startVC, animated: true)
        
//        performSegue(withIdentifier: "startSegue", sender: nil)
                
    }
    
    @IBAction func termsButton(_ sender: Any) {
        
    }
    

}
