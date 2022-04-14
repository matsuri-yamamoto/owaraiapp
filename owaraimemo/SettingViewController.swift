

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
//        let myReviewVC: MyReviewViewController = MyReviewViewController()
//        myReviewVC.tabBarController!.tabBar.isHidden = false
    }

    
    @IBAction func logoutButton(_ sender: Any) {
        // ログアウトする
        try! Auth.auth().signOut()
        
        // ログイン画面から戻ってきた時のためにさがすタブ（index = 0）を選択している状態にしておく
//        tabBarController?.selectedIndex = 0
        
        let startVC = self.storyboard?.instantiateViewController(identifier: "Start") as! StartViewController
        self.navigationController!.navigationBar.isHidden = true
        self.navigationController?.pushViewController(startVC, animated: true)
        self.tabBarController!.tabBar.isHidden = true

                        
    }
    
    @IBAction func termsButton(_ sender: Any) {
        
    }
}
