
import UIKit
import Firebase
import Firebase
import FirebaseFirestore

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    
    
    //オンボーディング後の場合にレビューを保存するための項目
    var afterOnboardFlag :String = ""
    var displayId :String = ""
    var comedianId :String = ""
    var comedianName :String = ""
    var score :Double = 0
    var comment :String = ""

//    var tag1: String = ""
//    var tag2: String = ""
//    var tag3: String = ""
//    var tag4: String = ""
//    var tag5: String = ""
//    let deleteDateTime :String? = nil

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
        
        
        if self.afterOnboardFlag == "true" {
            
            let newReviewTabVC = self.storyboard?.instantiateViewController(withIdentifier: "NewReviewTab") as! NewReviewTabViewController
            newReviewTabVC.afterOnboardFlag = "true"
            newReviewTabVC.displayId = self.displayId
            newReviewTabVC.comedianId = self.comedianId
            newReviewTabVC.comedianName = self.comedianName
            newReviewTabVC.score = self.score
            newReviewTabVC.comment = self.comment
            
            print("タブバー起動時ログイン状態：\(String(describing: currentUser?.uid))")

            print("tabbar_afterOnboardFlag:\(afterOnboardFlag)")
            print("tabbar_displayId:\(displayId)")
            print("tabbar_comedianId:\(comedianId)")
            print("tabbar_comedianName:\(comedianName)")
            print("tabbar_score:\(score)")
            print("tabbar_comment:\(comment)")
            
            

            
        }
                
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

