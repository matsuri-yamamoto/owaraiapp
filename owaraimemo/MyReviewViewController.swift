//
//
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorageUI

//ナビゲーションバーのボタンの変数
var settingButtonItem: UIBarButtonItem!

class MyReviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
        
    
//    @IBOutlet weak var userNameLabel: UILabel!
//    @IBOutlet weak var userIdLabel: UILabel!
    
//    @IBOutlet weak var reviewButtonWidth: NSLayoutConstraint!
    
    
    
        
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
    
    
//    @IBAction func reviewButton(_ sender: Any) {
//
//        //ボタンの色を切り替え
//        self.reviewButton.backgroundColor = UIColor.systemYellow
//        self.reviewButton.tintColor = #colorLiteral(red: 0.2442787347, green: 0.2442787347, blue: 0.2442787347, alpha: 1)
//
//        self.stockButton.backgroundColor = #colorLiteral(red: 1, green: 0.9310497734, blue: 0.695790851, alpha: 1)
//        self.stockButton.tintColor = #colorLiteral(red: 0.5989583532, green: 0.5618196744, blue: 0.5732305017, alpha: 1)
//
//        //comedianNameArrayとcomedianIdArrayの配列から一旦stockのデータを消す
//        self.comedianNameArray = []
//        self.comedianIdArray = []
//        self.comedianNameUniqueArray = []
//        self.comedianIdUniqueArray = []
//
//        self.tableView.reloadData()
//
//        //レビューデータを配列にセットする
//        db.collection("review").whereField("user_id", isEqualTo: Auth.auth().currentUser?.uid).order(by: "create_datetime", descending: true).getDocuments() { [self] (querySnapshot, err) in
//            if let err = err {
//                        print("Error getting documents: \(err)")
//                        return
//            } else {
//
//                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//
//                    //自分のレビューデータのcomedian_nameを配列に格納する
//                    self.comedianNameArray.append(document.data()["comedian_display_name"] as! String)
////                    print("comedianNameArray: \(self.comedianNameArray)")
//
//
//                    //自分のレビューデータのcomedian_idを配列に格納する
//                    self.comedianIdArray.append(document.data()["comedian_id"] as! String)
////                    print("comedianIdArray: \(self.comedianIdArray)")
//
//
//                    //comedian_nameの値をユニークにする
//                    var setName = Set<String>()
//                    self.comedianNameUniqueArray = self.comedianNameArray.filter { setName.insert($0).inserted }
////                    print("comedianUniqueArray: \(self.comedianNameUniqueArray)")
//
//                    //comedian_idの値をユニークにする
//                    var setData = Set<String>()
//                    self.comedianIdUniqueArray = self.comedianIdArray.filter { setData.insert($0).inserted }
////                    print("comedianUniqueArray: \(self.comedianIdUniqueArray)")
//
//                    self.tableView.reloadData()
//
//                }
//            }
//        }
//        //ログ
//        AnalyticsUtil.sendAction(ActionEvent(screenName: .myReviewVC,
//                                                     actionType: .tap,
//                                             actionLabel: .template(ActionLabelTemplate.myPageReviewButtonTap)))
//    }
//
//
//    @IBAction func stockButton(_ sender: Any) {
//
//        //ボタンの色を切り替え
//        self.stockButton.backgroundColor = UIColor.systemYellow
//        self.stockButton.tintColor = #colorLiteral(red: 0.2442787347, green: 0.2442787347, blue: 0.2442787347, alpha: 1)
//
//        self.reviewButton.backgroundColor = #colorLiteral(red: 1, green: 0.9310497734, blue: 0.695790851, alpha: 1)
//        self.reviewButton.tintColor = #colorLiteral(red: 0.5989583532, green: 0.5618196744, blue: 0.5732305017, alpha: 1)
//
//
//        //comedianNameArrayとcomedianIdArrayの配列から一旦reviewのデータを消す
//        self.comedianNameArray = []
//        self.comedianIdArray = []
//        self.comedianNameUniqueArray = []
//        self.comedianIdUniqueArray = []
//
//        self.tableView.reloadData()
//
//
//        //ストックデータを配列にセットする
//        db.collection("stock").whereField("user_id", isEqualTo: Auth.auth().currentUser?.uid).whereField("valid_flag", isEqualTo: true).order(by: "create_datetime", descending: true).getDocuments() { [self] (querySnapshot, err) in
//            if let err = err {
//                        print("Error getting documents: \(err)")
//                        return
//            } else {
//
//
//                    for document in querySnapshot!.documents {
//                        print("\(document.documentID) => \(document.data())")
//
//
//
//                        //自分のレビューデータのcomedian_nameを配列に格納する
//                        self.comedianNameArray.append(document.data()["comedian_display_name"] as! String)
////                        print("stockcomedianNameArray: \(self.comedianNameArray)")
//
//                        //自分のレビューデータのcomedian_idを配列に格納する
//                        self.comedianIdArray.append(document.data()["comedian_id"] as! String)
////                        print("stockcomedianIdArray: \(self.comedianIdArray)")
//
//                        //comedian_nameの値をユニークにする
//                        var setName = Set<String>()
//                        self.comedianNameUniqueArray = self.comedianNameArray.filter { setName.insert($0).inserted }
////                        print("stockcomedianUniqueArray: \(self.comedianNameUniqueArray)")
//
//                        //comedian_idの値をユニークにする
//                        var setData = Set<String>()
//                        self.comedianIdUniqueArray = self.comedianIdArray.filter { setData.insert($0).inserted }
////                        print("stockcomedianUniqueArray: \(self.comedianIdUniqueArray)")
//
//                        self.tableView.reloadData()
//                    }
//            }
//        }
//        //ログ
//        AnalyticsUtil.sendAction(ActionEvent(screenName: .myReviewVC,
//                                                     actionType: .tap,
//                                             actionLabel: .template(ActionLabelTemplate.myPageStockButtonTap)))
//
//
//    }
    
    
    
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
        
        let roundValue = round(self.scoreArray[indexPath.row]*10)/10
        cell.scoreLabel.text = String(roundValue)
        cell.scoreImageView.image = UIImage(named: "score_\(self.scoreArray[indexPath.row])")

        cell.commentLabel.text = self.commentArray[indexPath.row]
        cell.commentLabel.attributedText = cell.commentLabel.text?.attributedString(lineSpace: 5)
        cell.commentLabel.font = cell.commentLabel.font.withSize(12)
        cell.commentLabel.tintColor = UIColor.darkGray
        cell.commentLabel.textAlignment = NSTextAlignment.left
        
        cell.continuationButton.tag = indexPath.row
        cell.continuationButton.addTarget(self, action: #selector(tappedContinuationButton(sender:)), for: .touchUpInside)

        
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
        
        
        if cell.commentLabel.text!.count > 209 {
            
            cell.comedianNameButton.setTitle("全文を読む>", for: .normal)
            
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
        
        return 300
    
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //セルタップでレビュー画面に遷移
        let reviewVC = storyboard?.instantiateViewController(withIdentifier: "Review") as! ReviewViewController
        
        reviewVC.comedianID = self.comedianIdArray[indexPath.row]
        self.navigationController?.pushViewController(reviewVC, animated: true)
        hidesBottomBarWhenPushed = true

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

    
}
