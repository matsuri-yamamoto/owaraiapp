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
    
    @IBOutlet weak var reviewButton: UIButton!
    @IBOutlet weak var stockButton: UIButton!
//    @IBOutlet weak var userNameLabel: UILabel!
//    @IBOutlet weak var userIdLabel: UILabel!
    
//    @IBOutlet weak var reviewButtonWidth: NSLayoutConstraint!
    
    
    var tabFlag :String = ""
    
        
    var myReviewComedianNameArray: [String] = []
    var myReviewComedianNameUniqueArray: [String] = []

    var myReviewComedianIdArray: [String] = []
    var myReviewComedianIdUniqueArray: [String] = []
    
    var myReviewReviewIdArray: [String] = []
    var myReviewReviewIdUniqueArray: [String] = []
    
    var myReviewUpdatedArray: [String] = []
    var myReviewUpdatedUniqueArray: [String] = []

    var myReviewScoreArray: [String] = []
    var myReviewScoreUniqueArray: [String] = []
    
    var myReviewCommentArray: [String] = []
    var myReviewCommentUniqueArray: [String] = []
    
//    var myReviewRelationalArray: [String] = []
//    var myReviewRelationalUniqueArray: [String] = []
    
    var myReviewLikeReviewIdArray: [String] = []

    var reviewId :String = ""
    
    
    var cellSize :CGFloat = 0
    
    var comedianImageView = UIImageView()
    var comedianNameLabel = UILabel()

    
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


            
            reviewButton.isHidden = true
            stockButton.isHidden = true
            
            //ログ
            AnalyticsUtil.sendAction(ActionEvent(screenName: .myReviewVC,
                                                         actionType: .tap,
                                                 actionLabel: .template(ActionLabelTemplate.myPageRecLoginPush)))

        } else {
            
            db.collection("review").whereField("user_id", isEqualTo: Auth.auth().currentUser?.uid).order(by: "update_datetime", descending: true).getDocuments() { [self] (querySnapshot, err) in
                if let err = err {
                            print("Error getting documents: \(err)")
                            return
                } else {
            
                    for document in querySnapshot!.documents {
                        
                        //自分のレビューデータの各fieldを配列に格納する
                        
                        self.myReviewReviewIdArray.append(document.documentID as! String)
                        self.myReviewComedianNameArray.append(document.data()["comedian_display_name"] as! String)
                        self.myReviewComedianIdArray.append(document.data()["comedian_id"] as! String)
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = .short
                        dateFormatter.timeStyle = .short
                        dateFormatter.locale = Locale(identifier: "ja_JP")
                        dateFormatter.dateFormat = "yyyy/mm/dd hh:mm"
                        let updated = document.data()["update_datetime"] as! Timestamp
                        let updatedDate = updated.dateValue()
                        let updatedDateTime = dateFormatter.string(from: updatedDate)
                        self.myReviewUpdatedArray.append(updatedDateTime)
                        
                        let reviewFloatScoreArray = document.data()["score"] as! Float
                        self.myReviewScoreArray.append(String(reviewFloatScoreArray))
                        self.myReviewCommentArray.append(document.data()["comment"] as! String)
//                        self.myReviewRelationalArray.append(document.data()["relational_comedian_listname"] as! String)
                        
                        //すべての配列の値をユニークにする
                        var setmyReviewId = Set<String>()
                        self.myReviewReviewIdUniqueArray = self.myReviewReviewIdArray.filter { setmyReviewId.insert($0).inserted }
                        
                        var setmyReviewComedianName = Set<String>()
                        self.myReviewComedianNameUniqueArray = self.myReviewComedianNameArray.filter { setmyReviewComedianName.insert($0).inserted }
                        
                        var setmyReviewComedianId = Set<String>()
                        self.myReviewComedianIdUniqueArray = self.myReviewComedianIdArray.filter { setmyReviewComedianId.insert($0).inserted }
                        
                        var setmyReviewUpdated = Set<String>()
                        self.myReviewUpdatedUniqueArray = self.myReviewUpdatedArray.filter { setmyReviewUpdated.insert($0).inserted }
                        
                        var setmyReviewScore = Set<String>()
                        self.myReviewScoreUniqueArray = self.myReviewScoreArray.filter { setmyReviewScore.insert($0).inserted }
                        
                        var setmyReviewComment = Set<String>()
                        self.myReviewCommentUniqueArray = self.myReviewCommentArray.filter { setmyReviewComment.insert($0).inserted }
                        
//                        var setmyReviewRelational = Set<String>()
//                        self.myReviewRelationalUniqueArray = self.myReviewRelationalArray.filter { setmyReviewRelational.insert($0).inserted }
                                            
                    }
                    self.tableView.reloadData()
                }
            }

            
            
            self.tabFlag = "myReview"
        
            self.tableView.delegate = self
            self.tableView.dataSource = self

            
            //あとでみるに切り替えた状態から別タブに移動して戻ってきたときに、レビューを再度セットする処理
            self.myReviewComedianNameArray = []
            self.myReviewComedianIdArray = []
            self.tableView.reloadData()
            
            
//            self.reviewButtonWidth.constant = CGFloat(self.view.bounds.width/2)
            
            self.reviewButton.backgroundColor = UIColor.systemYellow
            self.reviewButton.tintColor = #colorLiteral(red: 0.2442787347, green: 0.2442787347, blue: 0.2442787347, alpha: 1)
            
            self.stockButton.backgroundColor = #colorLiteral(red: 1, green: 0.9310497734, blue: 0.695790851, alpha: 1)
            self.stockButton.tintColor = #colorLiteral(red: 0.5989583532, green: 0.5618196744, blue: 0.5732305017, alpha: 1)

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
        //ReviewVCに渡す用のComedianDataを取得する(対象となる芸人はmyReviewComedianNameArrayと同じだが、ComedianData型である必要があるため)
        //毎回データ更新してくれるように、viewDidAppearの中に記述する
        if myReviewComedianNameUniqueArray != [] {
            

        }
    
        //pvログ
        AnalyticsUtil.sendScreenName(ScreenEvent(screenName: .myReviewVC))
    }
    
    
    @IBAction func reviewButton(_ sender: Any) {
        
        //ボタンの色を切り替え
        self.reviewButton.backgroundColor = UIColor.systemYellow
        self.reviewButton.tintColor = #colorLiteral(red: 0.2442787347, green: 0.2442787347, blue: 0.2442787347, alpha: 1)
        
        self.stockButton.backgroundColor = #colorLiteral(red: 1, green: 0.9310497734, blue: 0.695790851, alpha: 1)
        self.stockButton.tintColor = #colorLiteral(red: 0.5989583532, green: 0.5618196744, blue: 0.5732305017, alpha: 1)
        
        //myReviewComedianNameArrayとmyReviewComedianIdArrayの配列から一旦stockのデータを消す
        self.myReviewComedianNameArray = []
        self.myReviewComedianIdArray = []
        self.myReviewComedianNameUniqueArray = []
        self.myReviewComedianIdUniqueArray = []
        
        self.tableView.reloadData()

        //レビューデータを配列にセットする
        db.collection("review").whereField("user_id", isEqualTo: Auth.auth().currentUser?.uid).order(by: "create_datetime", descending: true).getDocuments() { [self] (querySnapshot, err) in
            if let err = err {
                        print("Error getting documents: \(err)")
                        return
            } else {
        
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    //自分のレビューデータのcomedian_nameを配列に格納する
                    self.myReviewComedianNameArray.append(document.data()["comedian_display_name"] as! String)
//                    print("comedianNameArray: \(self.comedianNameArray)")


                    //自分のレビューデータのcomedian_idを配列に格納する
                    self.myReviewComedianIdArray.append(document.data()["comedian_id"] as! String)
//                    print("myReviewComedianIdArray: \(self.myReviewComedianIdArray)")

                    
                    //comedian_nameの値をユニークにする
                    var setName = Set<String>()
                    self.myReviewComedianNameUniqueArray = self.myReviewComedianNameArray.filter { setName.insert($0).inserted }
//                    print("comedianUniqueArray: \(self.myReviewComedianNameUniqueArray)")
                    
                    //comedian_idの値をユニークにする
                    var setData = Set<String>()
                    self.myReviewComedianIdUniqueArray = self.myReviewComedianIdArray.filter { setData.insert($0).inserted }
//                    print("comedianUniqueArray: \(self.myReviewComedianIdUniqueArray)")
                    
                    self.tableView.reloadData()
                                        
                }
            }
        }
        //ログ
        AnalyticsUtil.sendAction(ActionEvent(screenName: .myReviewVC,
                                                     actionType: .tap,
                                             actionLabel: .template(ActionLabelTemplate.myPageReviewButtonTap)))
    }
    
    
    @IBAction func stockButton(_ sender: Any) {
        
        //ボタンの色を切り替え
        self.stockButton.backgroundColor = UIColor.systemYellow
        self.stockButton.tintColor = #colorLiteral(red: 0.2442787347, green: 0.2442787347, blue: 0.2442787347, alpha: 1)
        
        self.reviewButton.backgroundColor = #colorLiteral(red: 1, green: 0.9310497734, blue: 0.695790851, alpha: 1)
        self.reviewButton.tintColor = #colorLiteral(red: 0.5989583532, green: 0.5618196744, blue: 0.5732305017, alpha: 1)
        

        //comedianNameArrayとmyReviewComedianIdArrayの配列から一旦reviewのデータを消す
        self.myReviewComedianNameArray = []
        self.myReviewComedianIdArray = []
        self.myReviewComedianNameUniqueArray = []
        self.myReviewComedianIdUniqueArray = []
        
        self.tableView.reloadData()

        
        //ストックデータを配列にセットする
        db.collection("stock").whereField("user_id", isEqualTo: Auth.auth().currentUser?.uid).whereField("valid_flag", isEqualTo: true).order(by: "create_datetime", descending: true).getDocuments() { [self] (querySnapshot, err) in
            if let err = err {
                        print("Error getting documents: \(err)")
                        return
            } else {
                
        
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        
                        
                        
                        //自分のレビューデータのcomedian_nameを配列に格納する
                        self.myReviewComedianNameArray.append(document.data()["comedian_display_name"] as! String)
//                        print("stockcomedianNameArray: \(self.comedianNameArray)")

                        //自分のレビューデータのcomedian_idを配列に格納する
                        self.myReviewComedianIdArray.append(document.data()["comedian_id"] as! String)
//                        print("stockmyReviewComedianIdArray: \(self.myReviewComedianIdArray)")
                        
                        //comedian_nameの値をユニークにする
                        var setName = Set<String>()
                        self.myReviewComedianNameUniqueArray = self.myReviewComedianNameArray.filter { setName.insert($0).inserted }
//                        print("stockcomedianUniqueArray: \(self.myReviewComedianNameUniqueArray)")
                        
                        //comedian_idの値をユニークにする
                        var setData = Set<String>()
                        self.myReviewComedianIdUniqueArray = self.myReviewComedianIdArray.filter { setData.insert($0).inserted }
//                        print("stockcomedianUniqueArray: \(self.myReviewComedianIdUniqueArray)")

                        self.tableView.reloadData()
                    }
            }
        }
        //ログ
        AnalyticsUtil.sendAction(ActionEvent(screenName: .myReviewVC,
                                                     actionType: .tap,
                                             actionLabel: .template(ActionLabelTemplate.myPageStockButtonTap)))

        
    }
    
    @IBAction func followingButton(_ sender: Any) {
    }

    
    @IBAction func likeListButton(_ sender: Any) {
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tabFlag == "myReview" {
            
            return self.myReviewReviewIdUniqueArray.count
            
        } else {
            
            return 0
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tabFlag == "myReview" {
            
            self.reviewId = self.myReviewReviewIdUniqueArray[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyReviewCell", for: indexPath) as! MyReviewTableViewCell
            
            cell.comedianNameLabel.text = self.myReviewComedianNameUniqueArray[indexPath.row]
            cell.scoreLabel.text = self.myReviewScoreUniqueArray[indexPath.row]
            cell.scoreImageView.image = UIImage(named: "score_\(self.myReviewScoreUniqueArray[indexPath.row])")

            cell.commentLabel.text = self.myReviewCommentUniqueArray[indexPath.row]
            cell.commentLabel.attributedText = cell.commentLabel.text?.attributedString(lineSpace: 5)
            cell.commentLabel.font = cell.commentLabel.font.withSize(12)
            cell.commentLabel.tintColor = UIColor.darkGray
            cell.commentLabel.textAlignment = NSTextAlignment.left
            
            //copyrightflagを取得して画像をセット
            db.collection("comedian").whereField(FieldPath.documentID(), isEqualTo: self.myReviewComedianIdUniqueArray[indexPath.row]).getDocuments() {(querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    return
                    
                } else {
                    for document in querySnapshot!.documents {
                        
                        let copyrightFlag = document.data()["copyright_flag"] as! String
                        
                        if copyrightFlag == "true" {
                            
                            let imageRef = self.storage.child("comedian_image/\(self.myReviewComedianIdUniqueArray[indexPath.row]).jpg")
                            cell.comedianImageView.sd_setImage(with: imageRef, placeholderImage: UIImage(named: "noImage"))
                            
                        }
                        
                        if copyrightFlag == "false" {
                            
                            cell.comedianImageView.image = UIImage(named: "noImage")
                            
                        }
                    }
                }
            }
            
            
            if cell.commentLabel.text!.count > 209 {
                
                cell.continuationLabel.text = "全文を読む>"
                
            } else {
                
                cell.continuationLabel.text = ""
                
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

        } else {
            
            //コード上のエラー回避用、実際は発動しない想定
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyReviewCell", for: indexPath) as! MyReviewTableViewCell

            return cell

        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
}
