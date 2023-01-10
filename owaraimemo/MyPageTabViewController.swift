//
//  MyPageTabViewController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/10/04.
//

import UIKit
import Tabman
import Pageboy
import Firebase
import FirebaseAuth

class MyPageTabViewController: TabmanViewController {
    
    
    var settingButtonItem: UIBarButtonItem!
    
    
    @IBOutlet weak var profileView: UIView!
    

    private var viewControllers = [UIViewController(), UIViewController(), UIViewController(), UIViewController()]
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userDisplayIdLabel: UILabel!

    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followedButton: UIButton!
    @IBOutlet weak var followingComedianButton: UIButton!
    
    
    let currentUser = Auth.auth().currentUser
    let db = Firestore.firestore()

    override func viewWillAppear(_ animated: Bool) {
        
        //フォロー中のユーザー数をカウント
        self.db.collection("follow").whereField("following_user_id", isEqualTo: currentUser?.uid).whereField("valid_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return

            } else {

                let documentCount = querySnapshot?.documents.count

                self.followingButton.setTitle("\(String(documentCount!)) フォロー中", for: .normal)
                self.followedButton.contentHorizontalAlignment = .left
                

            }
        }

        //フォロワー数をカウント
        self.db.collection("follow").whereField("followed_user_id", isEqualTo: currentUser?.uid).whereField("valid_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return

            } else {

                let documentCount = querySnapshot?.documents.count

                self.followedButton.setTitle("\(String(documentCount!)) フォロワー", for: .normal)
                self.followedButton.contentHorizontalAlignment = .left

            }
        }
        
//        //フォロー芸人数をカウント
//        self.db.collection("follow_comedian").whereField("user_id", isEqualTo: currentUser?.uid).whereField("valid_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//                return
//
//            } else {
//
//                let documentCount = querySnapshot?.documents.count
//
////                self.followedButton.setTitle("\(String(documentCount!)) 芸人さんフォロー", for: .normal)
//
//            }
//        }
        
        self.followedButton.contentHorizontalAlignment = .left

        
    }
    
    
    override func viewDidLoad() {


        super.viewDidLoad()
        
        self.followingComedianButton.layer.cornerRadius = 7
        self.followingComedianButton.clipsToBounds = true

        
        if currentUser?.uid == nil {
                        
            //ログインしていない場合、ログイン推奨ページに遷移
            let recLoginVC = storyboard?.instantiateViewController(withIdentifier: "RecLogin") as! RecommendLoginViewController
            
            self.navigationController?.pushViewController(recLoginVC, animated: true)


            
            
            //ログ
            AnalyticsUtil.sendAction(ActionEvent(screenName: .myReviewVC,
                                                         actionType: .tap,
                                                 actionLabel: .template(ActionLabelTemplate.myPageRecLoginPush)))

        } else {
            
            
            self.dataSource = self
            
            self.navigationItem.hidesBackButton = true
            self.title = "マイページ"
            
            self.view.bringSubviewToFront(self.profileView)
            
            
            
            // Create bar
            let bar = TMBar.ButtonBar()
            bar.layout.transitionStyle = .snap // Customize
            bar.backgroundView.style = .flat(color: .white)
            
            bar.layout.contentInset = UIEdgeInsets(top: 90.0, left: 10.0, bottom: 0.0, right: 10.0)
            
            bar.layout.contentMode = .fit
            
            //ボタンの間隔
            bar.layout.interButtonSpacing = 5

            bar.buttons.customize { (button) in
                button.tintColor = #colorLiteral(red: 0.2851759885, green: 0.2851759885, blue: 0.2851759885, alpha: 1)
                button.selectedTintColor = #colorLiteral(red: 0.1738873206, green: 0.1738873206, blue: 0.1738873206, alpha: 1)
                button.font = UIFont.systemFont(ofSize: 13)
                button.selectedFont = UIFont.boldSystemFont(ofSize: 13)
                button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            }
            bar.indicator.backgroundColor = #colorLiteral(red: 0.2851759885, green: 0.2851759885, blue: 0.2851759885, alpha: 1)
            bar.indicator.weight = .custom(value: 3)

            // Add to view
            addBar(bar, dataSource: self, at: .top)
            
            //ナビゲーションバーのボタン設置
            settingButtonItem = UIBarButtonItem(image: UIImage(systemName: "text.justify"), style: .done, target: self, action: #selector(settingButtonPressed))
            self.navigationItem.rightBarButtonItem = settingButtonItem
            
            navigationController?.navigationItem.leftBarButtonItem?.customView?.isHidden = true
            
            self.tabBarController?.tabBar.isHidden = false
            
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                    
                    
            //ユーザー名をセット
            self.userNameLabel.text = currentUser?.displayName

            //displayIdをセット
            self.db.collection("user_detail").whereField("user_id", isEqualTo: currentUser?.uid).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    return

                } else {
                    for document in querySnapshot!.documents {

                        let displayId = document.data()["display_id"] as! String
                        self.userDisplayIdLabel.text = "@" + displayId

                    }
                }
            }


            
        }

    }
        
    private func setTabsControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let firstVC = storyboard.instantiateViewController(withIdentifier: "MyCalendar") as! MyCalendarViewController

        let secondVC = storyboard.instantiateViewController(withIdentifier: "MyReview") as! MyReviewViewController
        let thirdVC = storyboard.instantiateViewController(withIdentifier: "Stock") as! StockViewController
        let forthVC = storyboard.instantiateViewController(withIdentifier: "LikeList") as! LikeListViewController
        
        viewControllers[0] = firstVC
        viewControllers[1] = secondVC
        viewControllers[2] = thirdVC
        viewControllers[3] = forthVC


    }
    
    @objc func settingButtonPressed() {
        
        let settingVC = storyboard?.instantiateViewController(withIdentifier: "Setting") as! SettingViewController
        
        self.navigationController?.pushViewController(settingVC, animated: true)

    }
    
    @IBAction func tappedFollowingButton(_ sender: Any) {
        
        let followUserVC = storyboard?.instantiateViewController(withIdentifier: "FollowUser") as! FollowUserViewController
        
        followUserVC.userType = "following"
        self.navigationController?.pushViewController(followUserVC, animated: true)

    }
    
    @IBAction func tappedFollowedButton(_ sender: Any) {
        
        let followUserVC = storyboard?.instantiateViewController(withIdentifier: "FollowUser") as! FollowUserViewController
        
        followUserVC.userType = "followed"
        self.navigationController?.pushViewController(followUserVC, animated: true)

        
    }
    
    @IBAction func tappedFollowingComedianButton(_ sender: Any) {
        
        let followUserVC = storyboard?.instantiateViewController(withIdentifier: "FollowUser") as! FollowUserViewController
        
        followUserVC.userType = "followingComedian"
        self.navigationController?.pushViewController(followUserVC, animated: true)

        
        if self.currentUser?.uid != "Wsp1fLJUadXIZEiwvpuPWvhEjNW2"
            && self.currentUser?.uid != "AxW7CvvgzTh0djyeb7LceI1dCYF2"
            && self.currentUser?.uid != "QWQcWLgi9AV21qtZRE6cIpgfaVp2"
            && self.currentUser?.uid != "BvNA6PJte0cj2u3FISymhnrBxCf2"
            && self.currentUser?.uid != "uHOTLNXbk8QyFPIoqAapj4wQUwF2"
            && self.currentUser?.uid != "z9fKAXmScrMTolTApapJyHyCfEg2"
            && self.currentUser?.uid != "jjF5m3lbU4bU0LKBgOTf0Hzs5RI3"
            && self.currentUser?.uid != "bjOQykO7RxPO8j1SdN88Z3Q8ELM2"
            && self.currentUser?.uid != "0GA1hPehpXdE2KKcKj0tPnCiQxA3"
            && self.currentUser?.uid != "i7KQ5WLDt3Q9pw9pSdGG6tCqZoL2"
            && self.currentUser?.uid != "wWgPk67GoIP9aBXrA7SWEccwStx1" {
            
            //pvログを取得
            let logRef = Firestore.firestore().collection("logs").document()
            let logDic = [
                "action_user_id": self.currentUser?.uid,
                "page": "MyPage",
                "action_type": "tap_following_comedian",
                "tapped_comedian_id": "",
                "tapped_user_id": "",
                "tapped_date": "",
                "tapped_event_id": "",
                "create_datetime": FieldValue.serverTimestamp(),
                "update_datetime": FieldValue.serverTimestamp(),
                "delete_flag": false,
                "delete_datetime": nil,
            ] as [String : Any]
            logRef.setData(logDic)
            
        }
        
    }
    
    
}



extension MyPageTabViewController: PageboyViewControllerDataSource, TMBarDataSource {

    //タブの数を決める
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        
        setTabsControllers()
        return viewControllers.count
    }
    
    //タブに該当するviewcontrollerを決める
    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }
    
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
    

    //タブバーの要件を決める
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        let title = ["カレンダー", "レビュー", "あとでみる", "いいね"]
        
//        var image1 = UIImage()
//        var image2 = UIImage()
//        var image3 = UIImage()
//
//        image1 = UIImage(systemName: "pencil.tip.crop.circle")!
//        image2 = UIImage(systemName: "paperclip.circle")!
//        image3 = UIImage(systemName: "heart.fill")!
//
//        let image = [image1, image2, image3]

        
        return TMBarItem(title: title[index])
        
        
        
    }
}
