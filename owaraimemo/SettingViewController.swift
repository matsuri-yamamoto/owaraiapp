

import UIKit
import Firebase

class SettingViewController: UIViewController {
    
    //ナビゲーションバーのボタンの変数
    var backButtonItem: UIBarButtonItem!
    

    
    override func viewWillAppear(_ animated: Bool) {
    
        //ナビゲーションバーのボタン設置
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(backButtonPressed))
        self.tabBarController!.tabBar.isHidden = true

        
    }
    
    @objc func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)

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
        
    }
    
    
}
