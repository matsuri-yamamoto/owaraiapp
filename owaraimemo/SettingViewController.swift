

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
    
    override func viewDidAppear(_ animated: Bool) {
        //pvログ
        AnalyticsUtil.sendScreenName(ScreenEvent(screenName: .settingVC))
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
        
        let termVC = storyboard?.instantiateViewController(withIdentifier: "Term") as! TermViewController
        self.navigationController?.pushViewController(termVC, animated: true)
        
    }
    
    @IBAction func ppButton(_ sender: Any) {
        
        let ppVC = storyboard?.instantiateViewController(withIdentifier: "PrivacyPolicy") as! TermViewController
        self.navigationController?.pushViewController(ppVC, animated: true)
        
    }
    
    @IBAction func inquiryButton(_ sender: Any) {
        
        let inquiryVC = storyboard?.instantiateViewController(withIdentifier: "Inquiry") as! InquiryViewController
        self.navigationController?.pushViewController(inquiryVC, animated: true)

    }
    
    
}


