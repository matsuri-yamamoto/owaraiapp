

import UIKit
import Tabman
import Pageboy
import Firebase
import FirebaseAuth

class ProfilePageTabViewController: TabmanViewController {
    
    
    var userId: String = ""
    var userName: String = ""
    var displayId: String = ""

    
    private var viewControllers = [UIViewController(), UIViewController(), UIViewController()]

    
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userDisplayIdLabel: UILabel!
    
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followedButton: UIButton!
    @IBOutlet weak var userFollowButton: UIButton!
    
    
    let currentUser = Auth.auth().currentUser
    let db = Firestore.firestore()
    
    var followFlag :String = ""
    var followId :String = ""

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //currentUserがフォロー中かどうか判定
        self.db.collection("follow").whereField("followed_user_id", isEqualTo: self.userId).whereField("following_user_id", isEqualTo: currentUser?.uid).whereField("valid_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return

            } else {
                
                //フォローしていない場合
                if querySnapshot?.documents.count == 0 {
                    
                    self.userFollowButton.setTitle("フォロー", for: .normal)
                    self.userFollowButton.backgroundColor = #colorLiteral(red: 0.1268742108, green: 0.1268742108, blue: 0.1268742108, alpha: 1)
                    self.userFollowButton.titleLabel?.tintColor = #colorLiteral(red: 0.9686005305, green: 0.9686005305, blue: 0.9686005305, alpha: 1)

                    self.followFlag = "false"
                    
                } else {
                    
                    for document in querySnapshot!.documents {
                        
                        self.followId = document.documentID
                        
                    }
                    
                    self.userFollowButton.setTitle("フォロー中", for: .normal)
                    self.userFollowButton.backgroundColor = #colorLiteral(red: 0.9686005305, green: 0.9686005305, blue: 0.9686005305, alpha: 1)
                    self.userFollowButton.titleLabel?.tintColor = #colorLiteral(red: 0.1268742108, green: 0.1268742108, blue: 0.1268742108, alpha: 1)
                    self.userFollowButton.layer.borderColor = #colorLiteral(red: 0.1268742108, green: 0.1268742108, blue: 0.1268742108, alpha: 1)
                    self.userFollowButton.layer.borderWidth = 1.0
                    
                    self.followFlag = "true"

                }
                
            }
        }
    }
    
    override func viewDidLoad() {
        
    
        print("プロフィールページuserID:\(self.userId)")
        
        super.viewDidLoad()

        self.dataSource = self
        
        self.navigationItem.hidesBackButton = true
        self.title = ""
        
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
        self.navigationItem.hidesBackButton = false

        self.tabBarController?.tabBar.isHidden = false
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                
                
        
        
        //ユーザー名をセット
        self.userNameLabel.text = self.userName
        
        
        //displayIdをセット
        self.db.collection("user_detail").whereField("user_id", isEqualTo: self.userId).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return

            } else {
                for document in querySnapshot!.documents {

                    self.displayId = document.data()["display_id"] as! String
                    self.userDisplayIdLabel.text = "@" + self.displayId

                }
            }
        }

        //フォロー中のユーザー数をカウント
        self.db.collection("follow").whereField("following_user_id", isEqualTo: self.userId).whereField("valid_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
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
        self.db.collection("follow").whereField("followed_user_id", isEqualTo: self.userId).whereField("valid_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return

            } else {

                let documentCount = querySnapshot?.documents.count

                self.followedButton.setTitle("\(String(documentCount!)) フォロワー", for: .normal)
                self.followedButton.contentHorizontalAlignment = .left
                



            }
        }

        //ボタンの角を丸くする
        self.userFollowButton.layer.cornerRadius = 15
        self.userFollowButton.clipsToBounds = true
        

    }
        
    private func setTabsControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let firstVC = storyboard.instantiateViewController(withIdentifier: "ProfileMyReview") as! ProfileMyReviewViewController
        let secondVC = storyboard.instantiateViewController(withIdentifier: "ProfileStock") as! ProfileStockViewController
        let thirdVC = storyboard.instantiateViewController(withIdentifier: "ProfileLikeList") as! ProfileLikeListViewController
        
        viewControllers[0] = firstVC
        viewControllers[1] = secondVC
        viewControllers[2] = thirdVC
        
        firstVC.profileUserId = self.userId
        secondVC.profileUserId = self.userId
        thirdVC.profileUserId = self.userId


    }
    
    
    @objc func settingButtonPressed() {
        
        performSegue(withIdentifier: "settingSegue", sender: nil)
        
    }
    
    @IBAction func tappedUserFollowButton(_ sender: Any) {
        
        var currentUserDisplayId :String = ""
        var currentUserName :String = ""
        let deleteDateTime :String? = nil

        //currentUserのuserNmae等を取得
        self.db.collection("user_detail").whereField("user_id", isEqualTo: currentUser?.uid).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return

            } else {
                for document in querySnapshot!.documents {
                    
                    currentUserDisplayId = document.data()["display_id"] as! String
                    
                }
                
                if self.followFlag == "true" {
                    
                    self.db.collection("follow").whereField("followed_user_id", isEqualTo: self.userId).whereField("following_user_id", isEqualTo: self.currentUser?.uid).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                            return

                        } else {
                            
                            
                            for document in querySnapshot!.documents {
                                
                                self.followId = document.documentID
                            }
                            
                            //既存のfollowデータのフラグをfalseにする
                            let existfollowRef = Firestore.firestore().collection("follow").document(self.followId)
                            existfollowRef.updateData([
                                "following_user_name": self.currentUser?.displayName,
                                "following_user_display_id": currentUserDisplayId,
                                "followed_user_name": self.userName,
                                "followed_user_display_id": self.displayId,
                                "valid_flag": false,
                                "update_datetime": FieldValue.serverTimestamp(),
                            ]) { err in
                                if let err = err {
                                    
                                    print("Error updating document: \(err)")
                                    
                                } else {
                                    
                                    print("Document successfully updated")
                                    
                                    //ボタンの色とテキストを変える
                                    self.userFollowButton.setTitle("フォロー", for: .normal)
                                    self.userFollowButton.backgroundColor = #colorLiteral(red: 0.1268742108, green: 0.1268742108, blue: 0.1268742108, alpha: 1)
                                    self.userFollowButton.titleLabel?.tintColor = #colorLiteral(red: 0.9686005305, green: 0.9686005305, blue: 0.9686005305, alpha: 1)
                                    
                                    self.followFlag = "false"


                                    
                                }
                            }
                        }
                    }

                }
                
                if self.followFlag == "false" {
                    
                    //ボタンの色とテキストを変える
                    self.userFollowButton.setTitle("フォロー中", for: .normal)
                    self.userFollowButton.backgroundColor = #colorLiteral(red: 0.9686005305, green: 0.9686005305, blue: 0.9686005305, alpha: 1)
                    self.userFollowButton.titleLabel?.tintColor = #colorLiteral(red: 0.1268742108, green: 0.1268742108, blue: 0.1268742108, alpha: 1)
                    self.userFollowButton.layer.borderColor = #colorLiteral(red: 0.1268742108, green: 0.1268742108, blue: 0.1268742108, alpha: 1)
                    self.userFollowButton.layer.borderWidth = 1.0

                    self.followFlag = "true"
                    
                    //既存のfollowデータの有無を調べる
                    //あればフラグをtrueにし、なければtrueでデータを作成する
                    self.db.collection("follow").whereField("followed_user_id", isEqualTo: self.userId).whereField("following_user_id", isEqualTo: self.currentUser?.uid).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                            return

                        } else {
                            //データがない場合
                            if querySnapshot?.documents.count == 0 {
                                
                                let followRef = Firestore.firestore().collection("follow").document()
                                let followDic = [
                                    "following_user_id": self.currentUser?.uid,
                                    "following_user_name": self.currentUser?.displayName,
                                    "following_user_display_id": currentUserDisplayId,
                                    "followed_user_id": self.userId,
                                    "followed_user_name": self.userName,
                                    "followed_user_display_id": self.displayId,
                                    "valid_flag": true,
                                    "create_datetime": FieldValue.serverTimestamp(),
                                    "update_datetime": FieldValue.serverTimestamp(),
                                    "delete_flag": false,
                                    "delete_datetime": deleteDateTime,
                                ] as [String : Any]
                                followRef.setData(followDic)

                            }
                            //データがある場合
                            if (querySnapshot?.documents.count)! > 0 {
                                
                                for document in querySnapshot!.documents {
                                    print("\(document.documentID) => \(document.data())")
                                    let documentId = document.documentID
                                    
                                    //ドキュメントidがnilでない場合、レビューを書いたことがあるということなのでドキュメントを更新する
                                    let existFollowRef = Firestore.firestore().collection("follow").document(documentId)
                                    existFollowRef.updateData([
                                        "following_user_name": self.currentUser?.displayName,
                                        "following_user_display_id": currentUserDisplayId,
                                        "followed_user_name": self.userName,
                                        "followed_user_display_id": self.displayId,
                                        "valid_flag": true,
                                        "update_datetime": FieldValue.serverTimestamp(),
                                    ]) { err in
                                        if let err = err {
                                            print("Error updating document: \(err)")
                                        } else {
                                            print("Document successfully updated")
                                            self.dismiss(animated: true)
                                        }
                                    }
                                }
                                
                            }
                            
                        }
                    }
   
                }
                
            }
        }

    }
    
    
    
    
    
    @IBAction func tappedFollowingButton(_ sender: Any) {

        
        let followUserVC = storyboard?.instantiateViewController(withIdentifier: "FollowUser") as! FollowUserViewController

        followUserVC.userType = "following"
        followUserVC.profileUserId = self.userId
        
        self.navigationController?.pushViewController(followUserVC, animated: true)

        
    }
    
    @IBAction func tappedFollowedButton(_ sender: Any) {
        
        let followUserVC = storyboard?.instantiateViewController(withIdentifier: "FollowUser") as! FollowUserViewController
        
        followUserVC.userType = "followed"
        followUserVC.profileUserId = self.userId

        
        self.navigationController?.pushViewController(followUserVC, animated: true)

    }

}



extension ProfilePageTabViewController: PageboyViewControllerDataSource, TMBarDataSource {
    
    
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
        let title = ["レビュー", "あとでみる", "いいね"]
        
        var image1 = UIImage()
        var image2 = UIImage()
        var image3 = UIImage()
        
        image1 = UIImage(systemName: "pencil.tip.crop.circle")!
        image2 = UIImage(systemName: "paperclip.circle")!
        image3 = UIImage(systemName: "heart.fill")!
        
        let image = [image1, image2, image3]

        
        return TMBarItem(title: title[index], image: image[index])
        
        
        
    }
}
