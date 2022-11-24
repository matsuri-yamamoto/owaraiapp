
import UIKit
import Firebase
import Firebase
import FirebaseFirestore

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    
    

    let currentUser = Auth.auth().currentUser
    let db = Firestore.firestore()


    
    override func viewDidLoad() {
        super.viewDidLoad()
        // タブアイコンの色
        self.tabBar.tintColor = UIColor.systemYellow
        self.tabBar.unselectedItemTintColor = UIColor.white
        // タブバーの背景色
        self.tabBar.barTintColor = #colorLiteral(red: 0.06914851636, green: 0.06914851636, blue: 0.06914851636, alpha: 1)
        // UITabBarControllerDelegateプロトコルのメソッドをこのクラスで処理する。
        self.delegate = self
        
        
                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //ナビゲーションバーの戻るボタンを非表示
        navigationController?.navigationBar.isHidden = true
        self.navigationItem.hidesBackButton = true


    }
    

    // タブバーのアイコンがタップされた時に呼ばれるdelegateメソッドを処理する。
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

            return true
    
        }

}

