//
//
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorageUI

//ナビゲーションバーのボタンの変数
var settingButtonItem: UIBarButtonItem!

class MyReviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
//    @IBOutlet weak var userNameLabel: UILabel!
//    @IBOutlet weak var userDisplayIdLabel: UILabel!
//
//    @IBOutlet weak var followingButton: UIButton!
//    @IBOutlet weak var followedButton: UIButton!

    
    
    @IBOutlet weak var tableView: UITableView!
        
            
    var comedianNameArray: [String] = []
//    var comedianNameUniqueArray: [String] = []

    var comedianIdArray: [String] = []
//    var comedianIdUniqueArray: [String] = []
    
    var reviewIdArray: [String] = []
//    var reviewIdUniqueArray: [String] = []
    
    var updatedArray: [String] = []
//    var updatedUniqueArray: [String] = []

    var scoreArray: [Double] = []
//    var scoreUniqueArray: [Double] = []
    
    var commentArray: [String] = []
//    var commentUniqueArray: [String] = []
    
//    var myReviewRelationalArray: [String] = []
//    var myReviewRelationalUniqueArray: [String] = []
    

    var reviewId :String = ""
        
    //Firestoreを使うための下準備
    let currentUser = Auth.auth().currentUser
    let db = Firestore.firestore()
    
    //いいねボタン用の画像
    let likeImage = UIImage(systemName: "heart.fill")
    let unLikeImage = UIImage(systemName: "heart")
    
    //画像のパス
    let storage = Storage.storage(url:"gs://owaraiapp-f80fd.appspot.com").reference()
    
    
    
    @objc func settingButtonPressed() {
        
        performSegue(withIdentifier: "settingSegue", sender: nil)
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        
        print("currentUser:\(String(describing: Auth.auth().currentUser?.uid))")
                
        if currentUser?.uid == nil {
                        
            //ログインしていない場合、ログイン推奨ページに遷移
            let recLoginVC = storyboard?.instantiateViewController(withIdentifier: "RecLogin") as! RecommendLoginViewController
            
            self.navigationController?.pushViewController(recLoginVC, animated: true)


            
            
            //ログ
            AnalyticsUtil.sendAction(ActionEvent(screenName: .myReviewVC,
                                                         actionType: .tap,
                                                 actionLabel: .template(ActionLabelTemplate.myPageRecLoginPush)))

        } else {
            
            //あとでみるに切り替えた状態から別タブに移動して戻ってきたときに、レビューを再度セットする処理
            self.comedianNameArray = []
            self.comedianIdArray = []
            self.reviewIdArray = []
            self.updatedArray = []
            self.scoreArray = []
            self.commentArray = []
            self.tableView.reloadData()

            
            db.collection("review").whereField("user_id", isEqualTo: Auth.auth().currentUser?.uid).order(by: "update_datetime", descending: true).getDocuments() { [self] (querySnapshot, err) in
                if let err = err {
                            print("Error getting documents: \(err)")
                            return
                } else {
            
                    for document in querySnapshot!.documents {
                        
                        //自分のレビューデータの各fieldを配列に格納する
                        
                        self.reviewIdArray.append(document.documentID as! String)
                        self.comedianNameArray.append(document.data()["comedian_display_name"] as! String)
                        self.comedianIdArray.append(document.data()["comedian_id"] as! String)
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = .short
                        dateFormatter.timeStyle = .short
                        dateFormatter.locale = Locale(identifier: "ja_JP")
                        dateFormatter.dateFormat = "yyyy/mm/dd hh:mm"
                        let updated = document.data()["update_datetime"] as! Timestamp
                        let updatedDate = updated.dateValue()
                        let updatedDateTime = dateFormatter.string(from: updatedDate)
                        self.updatedArray.append(updatedDateTime)
                        
                        self.scoreArray.append(document.data()["score"] as! Double)

                        self.commentArray.append(document.data()["comment"] as! String)
//                        self.myReviewRelationalArray.append(document.data()["relational_comedian_listname"] as! String)
                        
                                            
                    }
                    self.tableView.reloadData()
                }
            }

            
            
        
            self.tableView.delegate = self
            self.tableView.dataSource = self

            
            
                                    
            

            //セルを指定
            
            let nib = UINib(nibName: "MyReviewTableViewCell", bundle: nil)
            self.tableView.register(nib, forCellReuseIdentifier: "MyReviewCell")
            
            title = "マイページ"
            
            //ナビゲーションバーのボタン設置
            settingButtonItem = UIBarButtonItem(image: UIImage(systemName: "text.justify"), style: .done, target: self, action: #selector(settingButtonPressed))
            self.navigationItem.rightBarButtonItem = settingButtonItem
            
            navigationController?.navigationItem.leftBarButtonItem?.customView?.isHidden = true
            
            self.tabBarController?.tabBar.isHidden = false
            
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

                        
        }
    }
                
        
    override func viewDidAppear(_ animated: Bool) {
        //ReviewVCに渡す用のComedianDataを取得する(対象となる芸人はcomedianNameArrayと同じだが、ComedianData型である必要があるため)
        //毎回データ更新してくれるように、viewDidAppearの中に記述する
        if comedianNameArray != [] {
            

        }
    
        //pvログ
        AnalyticsUtil.sendScreenName(ScreenEvent(screenName: .myReviewVC))
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ユーザー名をセット
//        self.userNameLabel.text = currentUser?.displayName
//
//        //displayIdをセット
//        self.db.collection("user_detail").whereField("user_id", isEqualTo: currentUser?.uid).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//                return
//
//            } else {
//                for document in querySnapshot!.documents {
//
//                    self.userDisplayIdLabel.text = document.data()["display_id"] as! String
//
//                }
//            }
//        }
//
//        //フォロー中のユーザー数をカウント
//        self.db.collection("follow").whereField("following_user_id", isEqualTo: currentUser?.uid).whereField("valid_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//                return
//
//            } else {
//
//                let documentCount = querySnapshot?.documents.count
//
//                self.followingButton.setTitle(String(documentCount!), for: .normal)
//
//
//            }
//        }
//
//        //フォロワー数をカウント
//        self.db.collection("follow").whereField("followed_user_id", isEqualTo: currentUser?.uid).whereField("valid_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//                return
//
//            } else {
//
//                let documentCount = querySnapshot?.documents.count
//
//                self.followedButton.setTitle(String(documentCount!), for: .normal)
//
//
//            }
//        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                    
        return self.reviewIdArray.count
            
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        self.reviewId = self.reviewIdArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyReviewCell", for: indexPath) as! MyReviewTableViewCell
        
        cell.comedianNameButton.tag = indexPath.row
        cell.comedianNameButton.addTarget(self, action: #selector(tappedcomedianButton(sender:)), for: .touchUpInside)

        
        cell.comedianNameButton.contentHorizontalAlignment = .left
        cell.comedianNameButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        cell.comedianNameButton.setTitle(self.comedianNameArray[indexPath.row], for: .normal)
        cell.updatedLabel.text = "最終更新 - " + self.updatedArray[indexPath.row]
        
        
        
        let scoreText = String(format: "%.1f", self.scoreArray[indexPath.row])
        cell.scoreLabel.text = scoreText
        cell.scoreImageView.image = UIImage(named: "score_\(scoreText)")

        cell.commentLabel.text = self.commentArray[indexPath.row]
        cell.commentLabel.attributedText = cell.commentLabel.text?.attributedString(lineSpace: 5)
        cell.commentLabel.font = cell.commentLabel.font.withSize(12)
        cell.commentLabel.tintColor = UIColor.darkGray
        cell.commentLabel.textAlignment = NSTextAlignment.left
        
//        cell.continuationButton.tag = indexPath.row
//        cell.continuationButton.addTarget(self, action: #selector(tappedContinuationButton(sender:)), for: .touchUpInside)
//        cell.continuationButton.setTitle("全文を読む>", for: .normal)
//
//        print("行数(\(self.comedianIdArray[indexPath.row])：\(cell.commentLabel.lineNumber())")

        
        //copyrightflagを取得して画像をセット
        db.collection("comedian").whereField(FieldPath.documentID(), isEqualTo: self.comedianIdArray[indexPath.row]).getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                for document in querySnapshot!.documents {
                    
                    let copyrightFlag = document.data()["copyright_flag"] as! String
                    
                    if copyrightFlag == "true" {
                        
                        let imageRef = self.storage.child("comedian_image/\(self.comedianIdArray[indexPath.row]).jpg")
                        cell.comedianImageView.sd_setImage(with: imageRef, placeholderImage: UIImage(named: "noImage"))
                        
                    }
                    
                    if copyrightFlag == "false" {
                        
                        cell.comedianImageView.image = UIImage(named: "noImage")
                        
                    }
                }
            }
        }
        

        //likereviewをセット
        db.collection("like_review").whereField("review_id", isEqualTo: self.reviewId).whereField("like_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                
                cell.likeCountLabel.text = "\(querySnapshot!.documents.count)"
            }
        }
        
        
        
        
//            //relationalcomedianがいる場合はセット、いない場合は空白
//            if self.myReviewRelationalUniqueArray[indexPath.row] == "" {
//
//                cell.beforeRelationalLabel.text = ""
//                cell.relationalComedianLabel.text = ""
//                cell.afterRelationalLabel.text = ""
//
//            }
//
//            if self.myReviewRelationalUniqueArray[indexPath.row] != "" {
//
//                cell.beforeRelationalLabel.text = "この芸人さんは"
//                cell.relationalComedianLabel.text = self.myReviewRelationalUniqueArray[indexPath.row]
//                cell.afterRelationalLabel.text = "が好きな人にハマりそう！"
//
//            }
        

        return cell

    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 350
    
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //セルタップでレビュー画面に遷移
//        let reviewVC = storyboard?.instantiateViewController(withIdentifier: "Review") as! ReviewViewController
//
//        reviewVC.comedianID = self.comedianIdArray[indexPath.row]
//        self.navigationController?.pushViewController(reviewVC, animated: true)
//        hidesBottomBarWhenPushed = true
        
        
        
        let reviewVC = storyboard?.instantiateViewController(withIdentifier: "Review") as! ReviewViewController
        let nav = UINavigationController(rootViewController: reviewVC)
        
        //comedian_idを渡す
        reviewVC.comedianID = self.comedianIdArray[indexPath.row]
        
        reviewVC.comedianName = self.comedianNameArray[indexPath.row]
        
        self.present(nav, animated: true, completion: nil)
        
        //ログ
        AnalyticsUtil.sendAction(ActionEvent(screenName: .comedianDetailVC,
                                                     actionType: .tap,
                                             actionLabel: .template(ActionLabelTemplate.reviewButtonTap)))

        
        

    }
    
    //芸人名タップでcomedianDetailに遷移
    @objc func tappedcomedianButton(sender: UIButton) {
        
        
        let buttonTag = sender.tag
        let tappedComedianId = self.comedianIdArray[buttonTag]
        
        let button = sender
        let cell = button.superview?.superview as! MyReviewTableViewCell
        
        //セルタップでレビュー全文に遷移
        let comedianVC = storyboard?.instantiateViewController(withIdentifier: "Comedian") as! ComedianDetailViewController
        
        comedianVC.comedianId = tappedComedianId
        self.navigationController?.pushViewController(comedianVC, animated: true)
        hidesBottomBarWhenPushed = true
        
        
    }
    
    @objc func tappedContinuationButton(sender: UIButton) {
        
        
        let buttonTag = sender.tag
        let tappedReviewId = self.reviewIdArray[buttonTag]
        
        let button = sender
        let cell = button.superview?.superview as! MyReviewTableViewCell
        
        //セルタップでレビュー全文に遷移
        let AllReviewVC = storyboard?.instantiateViewController(withIdentifier: "AllReview") as! AllReviewViewController
        
        AllReviewVC.reviewId = tappedReviewId
        self.navigationController?.pushViewController(AllReviewVC, animated: true)
        hidesBottomBarWhenPushed = true
        
        
    }
    
    @IBAction func tappedFollowingButton(_ sender: Any) {
    }
    
    @IBAction func tappedFollowedButton(_ sender: Any) {
    }
    
    
    
    
    

    
}

extension UILabel {

  /// 行数を返す
  func lineNumber() -> Int {
    let oneLineRect  =  "a".boundingRect(
      with: self.bounds.size,
      options: .usesLineFragmentOrigin,
      attributes: [NSAttributedString.Key.font: self.font ?? UIFont()],
      context: nil
    )
    let boundingRect = (self.text ?? "").boundingRect(
      with: self.bounds.size,
      options: .usesLineFragmentOrigin,
      attributes: [NSAttributedString.Key.font: self.font ?? UIFont()],
      context: nil
    )

    return Int(boundingRect.height / oneLineRect.height)
  }

}
