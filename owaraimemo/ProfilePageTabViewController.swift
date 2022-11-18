

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
    
    @IBOutlet weak var blockLabel: UILabel!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userDisplayIdLabel: UILabel!
    
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followedButton: UIButton!
    @IBOutlet weak var userFollowButton: UIButton!
    @IBOutlet weak var alertButton: UIButton!
    
    
    let currentUser = Auth.auth().currentUser
    let db = Firestore.firestore()
    
    var blockingFlag :String = ""
    var blockId :String = ""
    var followFlag :String = ""
    var followId :String = ""
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("プロフィールページuserId:\(self.userId)")
        
        
        //ブロック中かどうか判定
        self.db.collection("block_user").whereField("blocked_user_id", isEqualTo: self.userId).whereField("blocking_user_id", isEqualTo: self.currentUser?.uid).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                //データがない場合
                if querySnapshot?.documents.count == 0 {
                    
                    self.blockingFlag = "no_block"
                    
                    //ブロックされていないかをチェックする
                    self.checkBlockedStatus()
                    
                }
                //データがある場合
                if (querySnapshot?.documents.count)! > 0 {
                    
                    for document in querySnapshot!.documents {
                        
                        self.blockId = document.documentID as! String
                        let validFlag = document.data()["valid_flag"] as! Bool
                        //trueの場合
                        if validFlag == true {
                            
                            self.blockingFlag = "now_block"
                            
                            //フォローボタンをブロック状態にする
                            self.userFollowButton.setTitle("ブロック中", for: .normal)
                            self.userFollowButton.backgroundColor = #colorLiteral(red: 0.9686005305, green: 0.9686005305, blue: 0.9686005305, alpha: 1)
                            self.userFollowButton.titleLabel?.tintColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                            self.userFollowButton.layer.borderColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                            self.userFollowButton.layer.borderWidth = 1.0
                            
                            self.blockLabel.text = "このユーザーをブロックしています"
                            self.alertButton.isHidden = true
                            self.followingButton.isHidden = true
                            self.followedButton.isHidden = true
                            
                        }
                        //falseの場合
                        if validFlag == false {
                            
                            self.blockingFlag = "past_block"
                            
                            //ブロックされていないかをチェックする
                            self.checkBlockedStatus()
                            
                        }
                        
                        
                    }
                    
                    
                }
            }
        }
        
        
    }
    
    
    func checkBlockedStatus() {
        //ブロックされているかどうか判定
        self.db.collection("block_user").whereField("blocking_user_id", isEqualTo: self.userId).whereField("blocked_user_id", isEqualTo: self.currentUser?.uid).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                //データがない場合
                if querySnapshot?.documents.count == 0 {
                    
                    self.blockLabel.isHidden = true
                    self.checkFollowStatus()
                    
                }
                //データがある場合
                if (querySnapshot?.documents.count)! > 0 {
                    
                    for document in querySnapshot!.documents {
                        
                        let validFlag = document.data()["valid_flag"] as! Bool
                        
                        //trueの場合
                        if validFlag == true {
                            
                            //フォローボタンを非表示
                            self.userFollowButton.isHidden = true
                            self.alertButton.isHidden = true
                            self.followingButton.isHidden = true
                            self.followedButton.isHidden = true
                            
                            self.blockLabel.text = "このユーザーは" + "\n" + "あなたをブロックしています"
                            
                            
                        }
                        //falseの場合
                        if validFlag == false {
                            
                            //通常の画面として表示、フォロー状態をチェックする
                            self.blockLabel.isHidden = true
                            self.checkFollowStatus()
                            
                        }
                        
                        
                    }
                    
                }
            }
        }
        
        
        
    }
    
    
    //currentUserがフォロー中かどうか判定
    func checkFollowStatus() {
        
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
        
        //アラートボタンのテキスト設定
        self.alertButton.setTitle("", for: .normal)
        
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
        
        
        
        if currentUser?.uid == nil {
            
            //ログインしていない場合、ログイン推奨ページに遷移
            let recLoginVC = storyboard?.instantiateViewController(withIdentifier: "RecLogin") as! RecommendLoginViewController
            
            self.navigationController?.pushViewController(recLoginVC, animated: true)
            
            
            
            
            //ログ
            AnalyticsUtil.sendAction(ActionEvent(screenName: .myReviewVC,
                                                 actionType: .tap,
                                                 actionLabel: .template(ActionLabelTemplate.myPageRecLoginPush)))
            
        } else {
            
            //ブロック中なら、ブロック解除
            if self.blockingFlag == "now_block" {
                
                //ボタンの見た目を、未ブロック・フォロー前の状態に戻す
                self.userFollowButton.setTitle("フォロー", for: .normal)
                self.userFollowButton.backgroundColor = #colorLiteral(red: 0.1268742108, green: 0.1268742108, blue: 0.1268742108, alpha: 1)
                self.userFollowButton.titleLabel?.tintColor = #colorLiteral(red: 0.9686005305, green: 0.9686005305, blue: 0.9686005305, alpha: 1)
                self.userFollowButton.layer.borderColor = #colorLiteral(red: 0.1268742108, green: 0.1268742108, blue: 0.1268742108, alpha: 1)

                
                self.followFlag = "false"
                
                self.blockLabel.isHidden = true
                
                self.alertButton.isHidden = false
                self.followingButton.isHidden = false
                self.followedButton.isHidden = false
                
                
                //block_userのvalid_flagをfalseにする
                let existBlockRef = Firestore.firestore().collection("block_user").document(self.blockId)
                existBlockRef.updateData([
                    "valid_flag": false,
                    "update_datetime": FieldValue.serverTimestamp(),
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                    }
                }
                
            }
            
            //ブロック中じゃなければフォローの切り替え
            if self.blockingFlag != "now_block" {
                
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
    
    @IBAction func tappedAlertButton(_ sender: Any) {
        
        //UIAlertControllerを用意する
        let actionChoiceAlert = UIAlertController(title: "報告・ブロック", message: "ユーザーを報告・ブロックしますか？", preferredStyle: UIAlertController.Style.actionSheet)
        
        //UIAlertControllerにブロックのアクションを追加する
        let blockActionChoice = UIAlertAction(title: "ブロックする", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            
            
            if self.currentUser?.uid == nil {
                //ログインしていない場合、ログイン推奨ページに遷移
                let recLoginVC = self.storyboard?.instantiateViewController(withIdentifier: "RecLogin") as! RecommendLoginViewController
                
                self.navigationController?.pushViewController(recLoginVC, animated: true)
                
                //ログ
                AnalyticsUtil.sendAction(ActionEvent(screenName: .comedianDetailVC,
                                                     actionType: .tap,
                                                     actionLabel: .template(ActionLabelTemplate.comedianLikeReviewReLoginPush)))
            } else {
                
                //本当にブロックしていいのかダイアログを出す
                let blockAlert = UIAlertController(title: "このユーザーをブロックする", message: "このユーザーとあなたには、双方のレビューが表示されなくなります。またこのユーザーはあなたをフォローできなくなります。", preferredStyle: UIAlertController.Style.alert)
                
                //UIAlertControllerにキャンセルのアクションを追加する
                let blockCancelChoice = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: {
                    (action: UIAlertAction!) in
                    
                    return
                })
                blockAlert.addAction(blockCancelChoice)
                
                //UIAlertControllerにブロックのアクションを追加する
                let blockExeChoice = UIAlertAction(title: "ブロック", style: UIAlertAction.Style.default, handler: {
                    (action: UIAlertAction!) in
                    
                    
                    //既存のブロックドキュメントがないか調べ、ない場合はblockドキュメントを作成
                    if self.blockingFlag == "no_block"{
                        
                        //ブロックドキュメントを作成
                        let deleteDateTime :String? = nil
                        
                        let blockRef = Firestore.firestore().collection("block_user").document()
                        let blockDic = [
                            "blocking_user_id": self.currentUser?.uid,
                            "blocked_user_id": self.userId,
                            "valid_flag": true,
                            "create_datetime": FieldValue.serverTimestamp(),
                            "update_datetime": FieldValue.serverTimestamp(),
                            "delete_flag": false,
                            "delete_datetime": deleteDateTime,
                        ] as [String : Any]
                        blockRef.setData(blockDic)

                        
                    } else {
                        //blockドキュメントがあればvalid_flagをtrueにアップデート
                        let existBlockRef = Firestore.firestore().collection("block_user").document(self.blockId)
                        existBlockRef.updateData([
                            "valid_flag": true,
                            "update_datetime": FieldValue.serverTimestamp(),
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                            }
                        }
                        
                    }
                                        
                    //自分がfollowingのtrueのfollowがあればフラグをfalseにする
                    self.db.collection("follow").whereField("followed_user_id", isEqualTo: self.userId).whereField("following_user_id", isEqualTo: self.currentUser?.uid).whereField("delete_flag", isEqualTo: false).whereField("valid_flag", isEqualTo: true).getDocuments() {(querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                            return
                            
                        } else {
                            //データがない場合
                            if querySnapshot?.documents.count == 0 {
                                
                                return
                                
                            }
                            //データがある場合
                            if (querySnapshot?.documents.count)! > 0 {
                                
                                for document in querySnapshot!.documents {
                                    print("\(document.documentID) => \(document.data())")
                                    let documentId = document.documentID
                                    
                                    let existFollowRef = Firestore.firestore().collection("follow").document(documentId)
                                    existFollowRef.updateData([
                                        "valid_flag": false,
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
                    
                    //相手がfollowingのtrueのfollowがあればフラグをfalseにする
                    self.db.collection("follow").whereField("followed_user_id", isEqualTo: self.currentUser?.uid).whereField("following_user_id", isEqualTo: self.userId).whereField("delete_flag", isEqualTo: false).whereField("valid_flag", isEqualTo: true).getDocuments() {(querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                            return
                            
                        } else {
                            //データがない場合
                            if querySnapshot?.documents.count == 0 {
                                
                                return
                                
                            }
                            //データがある場合
                            if (querySnapshot?.documents.count)! > 0 {
                                
                                for document in querySnapshot!.documents {
                                    print("\(document.documentID) => \(document.data())")
                                    let documentId = document.documentID
                                    
                                    let existFollowRef = Firestore.firestore().collection("follow").document(documentId)
                                    existFollowRef.updateData([
                                        "valid_flag": false,
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
                    
                    
                    
                    
                    
                    
                    //NewRreviewVCに戻す
                    let newReviewVC = self.storyboard?.instantiateViewController(withIdentifier: "NewReviewTab") as! NewReviewTabViewController
                    self.navigationController?.pushViewController(newReviewVC, animated: true)
                    
                })
                blockAlert.addAction(blockExeChoice)
                
                //アクションを表示する
                self.present(blockAlert, animated: true, completion: nil)
                
            }
            
            
        })
        actionChoiceAlert.addAction(blockActionChoice)
        
        
        //UIAlertControllerに報告のアクションを追加する
        let reportActionChoice = UIAlertAction(title: "報告する", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            
            let inquiryVC = self.storyboard?.instantiateViewController(withIdentifier: "Inquiry") as! InquiryViewController
            self.navigationController?.pushViewController(inquiryVC, animated: true)
            
        })
        actionChoiceAlert.addAction(reportActionChoice)
        
        
        //UIAlertControllerにキャンセルのアクションを追加する
        let cancelActionChoice = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: {
            (action: UIAlertAction!) in
            
            return
        })
        actionChoiceAlert.addAction(cancelActionChoice)
        
        //アクションを表示する
        present(actionChoiceAlert, animated: true, completion: nil)
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
