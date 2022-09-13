//
//
import UIKit
import Firebase
import FirebaseFirestore

//ナビゲーションバーのボタンの変数
var settingButtonItem: UIBarButtonItem!

class MyReviewViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var reviewButton: UIButton!
    @IBOutlet weak var stockButton: UIButton!
//    @IBOutlet weak var userNameLabel: UILabel!
//    @IBOutlet weak var userIdLabel: UILabel!
    
    @IBOutlet weak var reviewButtonWidth: NSLayoutConstraint!
    
    
        
    var comedianNameArray: [String] = []
    var comedianNameUniqueArray: [String] = []

    var comedianDataArray: [String] = []
    var comedianDataUniqueArray: [String] = []
    
    var cellSize :CGFloat = 0
    
    var comedianImageView = UIImageView()
    var comedianNameLabel = UILabel()

    
    //Firestoreを使うための下準備
    let currentUser = Auth.auth().currentUser
    let db = Firestore.firestore()
    
    

    
    @IBOutlet weak var collectionView: UICollectionView!
    
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
            
        
            collectionView.delegate = self
            collectionView.dataSource = self
            
            
            //あとでみるに切り替えた状態から別タブに移動して戻ってきたときに、レビューを再度セットする処理
            self.comedianNameArray = []
            self.comedianDataArray = []
            self.collectionView.reloadData()
            
            
            self.reviewButtonWidth.constant = CGFloat(self.view.bounds.width/2)
            
            self.reviewButton.backgroundColor = UIColor.systemYellow
            self.reviewButton.tintColor = #colorLiteral(red: 0.2442787347, green: 0.2442787347, blue: 0.2442787347, alpha: 1)
            
            self.stockButton.backgroundColor = #colorLiteral(red: 1, green: 0.9310497734, blue: 0.695790851, alpha: 1)
            self.stockButton.tintColor = #colorLiteral(red: 0.5989583532, green: 0.5618196744, blue: 0.5732305017, alpha: 1)

            //セルを指定
            collectionView.register(UINib(nibName: "TabViewCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TabViewCollectionViewCell")
            
            //セルのサイズを指定
            let layout = UICollectionViewFlowLayout()
            // 横方向のスペース調整
            let horizontalSpace:CGFloat = 50
            //デバイスの横幅を2分割した横幅　- セル間のスペース*1（セル間のスペースが1列あるため）
            cellSize = (self.view.bounds.width - horizontalSpace*1)/2
            
            print("firstTabcellSize:\(cellSize)")

            
            layout.itemSize = CGSize(width: cellSize, height: cellSize*1.35)
            collectionView.collectionViewLayout = layout
            
            
            title = "マイページ"
            
            //ナビゲーションバーのボタン設置
            settingButtonItem = UIBarButtonItem(image: UIImage(systemName: "text.justify"), style: .done, target: self, action: #selector(settingButtonPressed))
            self.navigationItem.rightBarButtonItem = settingButtonItem
            
            navigationController?.navigationItem.leftBarButtonItem?.customView?.isHidden = true
            
            self.tabBarController?.tabBar.isHidden = false
            
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

            
            
            db.collection("review").whereField("user_id", isEqualTo: Auth.auth().currentUser?.uid).order(by: "create_datetime", descending: true).getDocuments() { [self] (querySnapshot, err) in
                if let err = err {
                            print("Error getting documents: \(err)")
                            return
                } else {
            
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        
                        //自分のレビューデータのcomedian_nameを配列に格納する
                        self.comedianNameArray.append(document.data()["comedian_display_name"] as! String)
//                        print("comedianNameArray: \(self.comedianNameArray)")


                        //自分のレビューデータのcomedian_idを配列に格納する
                        self.comedianDataArray.append(document.data()["comedian_id"] as! String)
//                        print("comedianDataArray: \(self.comedianDataArray)")

                        
                        //comedian_nameの値をユニークにする
                        var setName = Set<String>()
                        self.comedianNameUniqueArray = self.comedianNameArray.filter { setName.insert($0).inserted }
//                        print("comedianUniqueArray: \(self.comedianNameUniqueArray)")
                        
                        //comedian_idの値をユニークにする
                        var setData = Set<String>()
                        self.comedianDataUniqueArray = self.comedianDataArray.filter { setData.insert($0).inserted }
//                        print("comedianUniqueArray: \(self.comedianDataUniqueArray)")
            
                                            
                    }
                    collectionView.reloadData()
                }
            }
            
//            //ユーザー名をセット
//            self.userNameLabel.text = currentUser?.displayName as? String
//
//            //ユーザーIDをセット
//            db.collection("user_detail").whereField("user_id", isEqualTo: currentUser?.uid).getDocuments() {  (querySnapshot, err) in
//                if let err = err {
//                            print("Error getting documents: \(err)")
//                            return
//                } else {
//
//                    for document in querySnapshot!.documents {
//
//                        self.userIdLabel.text = "@" + "\(document.data()["display_id"]! as? String?)"
//
//                    }
//                }
//            }
            
        }
    }
                
        
    override func viewDidAppear(_ animated: Bool) {
        //ReviewVCに渡す用のComedianDataを取得する(対象となる芸人はComedianNameArrayと同じだが、ComedianData型である必要があるため)
        //毎回データ更新してくれるように、viewDidAppearの中に記述する
        if comedianNameUniqueArray != [] {
            

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
        
        //comedianNameArrayとcomedianDataArrayの配列から一旦stockのデータを消す
        self.comedianNameArray = []
        self.comedianDataArray = []
        self.comedianNameUniqueArray = []
        self.comedianDataUniqueArray = []
        
        self.collectionView.reloadData()

        //レビューデータを配列にセットする
        db.collection("review").whereField("user_id", isEqualTo: Auth.auth().currentUser?.uid).order(by: "create_datetime", descending: true).getDocuments() { [self] (querySnapshot, err) in
            if let err = err {
                        print("Error getting documents: \(err)")
                        return
            } else {
        
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    //自分のレビューデータのcomedian_nameを配列に格納する
                    self.comedianNameArray.append(document.data()["comedian_display_name"] as! String)
//                    print("comedianNameArray: \(self.comedianNameArray)")


                    //自分のレビューデータのcomedian_idを配列に格納する
                    self.comedianDataArray.append(document.data()["comedian_id"] as! String)
//                    print("comedianDataArray: \(self.comedianDataArray)")

                    
                    //comedian_nameの値をユニークにする
                    var setName = Set<String>()
                    self.comedianNameUniqueArray = self.comedianNameArray.filter { setName.insert($0).inserted }
//                    print("comedianUniqueArray: \(self.comedianNameUniqueArray)")
                    
                    //comedian_idの値をユニークにする
                    var setData = Set<String>()
                    self.comedianDataUniqueArray = self.comedianDataArray.filter { setData.insert($0).inserted }
//                    print("comedianUniqueArray: \(self.comedianDataUniqueArray)")
                    
                    collectionView.reloadData()
                                        
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
        

        //comedianNameArrayとcomedianDataArrayの配列から一旦reviewのデータを消す
        self.comedianNameArray = []
        self.comedianDataArray = []
        self.comedianNameUniqueArray = []
        self.comedianDataUniqueArray = []
        
        self.collectionView.reloadData()

        
        //ストックデータを配列にセットする
        db.collection("stock").whereField("user_id", isEqualTo: Auth.auth().currentUser?.uid).whereField("valid_flag", isEqualTo: true).order(by: "create_datetime", descending: true).getDocuments() { [self] (querySnapshot, err) in
            if let err = err {
                        print("Error getting documents: \(err)")
                        return
            } else {
                
        
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        
                        
                        
                        //自分のレビューデータのcomedian_nameを配列に格納する
                        self.comedianNameArray.append(document.data()["comedian_display_name"] as! String)
//                        print("stockcomedianNameArray: \(self.comedianNameArray)")

                        //自分のレビューデータのcomedian_idを配列に格納する
                        self.comedianDataArray.append(document.data()["comedian_id"] as! String)
//                        print("stockcomedianDataArray: \(self.comedianDataArray)")
                        
                        //comedian_nameの値をユニークにする
                        var setName = Set<String>()
                        self.comedianNameUniqueArray = self.comedianNameArray.filter { setName.insert($0).inserted }
//                        print("stockcomedianUniqueArray: \(self.comedianNameUniqueArray)")
                        
                        //comedian_idの値をユニークにする
                        var setData = Set<String>()
                        self.comedianDataUniqueArray = self.comedianDataArray.filter { setData.insert($0).inserted }
//                        print("stockcomedianUniqueArray: \(self.comedianDataUniqueArray)")

                        self.collectionView.reloadData()
                    }
            }
        }
        //ログ
        AnalyticsUtil.sendAction(ActionEvent(screenName: .myReviewVC,
                                                     actionType: .tap,
                                             actionLabel: .template(ActionLabelTemplate.myPageStockButtonTap)))

        
    }
    
    
    
    
    
    
    // データの数（＝セルの数）を返すメソッド
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if comedianNameUniqueArray != [] {
            
            return comedianNameUniqueArray.count
            
        } else {
            
            return 0
            
        }
    }

    // 各セルの内容を返すメソッド
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        //storyboard上のセルを生成　storyboardのIdentifierで付けたものをここで設定する
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TabViewCollectionViewCell", for: indexPath) as! TabViewCollectionViewCell

        //芸人画像を指定する
        

        
        
        let image :UIImage? = UIImage(named: "\(comedianDataUniqueArray[indexPath.row])")
        let noImage :UIImage! = UIImage(named: "noImage")

        //copyrightflagを加味できておらず、画像がAssetsにアップロードされ次第表示されてしまうので注意
        if let validImage = image {
            cell.comedianImageView.image = validImage
            cell.comedianImageView.contentMode = .scaleAspectFill
            cell.comedianImageView.clipsToBounds = true
            
        } else {
            cell.comedianImageView.image = noImage
            cell.comedianImageView.contentMode = .scaleAspectFill
            cell.comedianImageView.clipsToBounds = true

        }
        
        //芸人名を設定する
        cell.comedianNameLabel.text = comedianNameUniqueArray[indexPath.row]

        
        return cell
    }
    
//    //セルのサイズを指定する処理
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        // 横方向のスペース調整
//        let horizontalSpace:CGFloat = 50
//
//        //デバイスの横幅を2分割した横幅　- セル間のスペース*1（セル間のスペースが1列あるため）
//        cellSize = (self.view.bounds.width - horizontalSpace*1)/2
//
//        return CGSize(width: cellSize, height: cellSize*1.35)
//
//    }
    

    // 各セルを選択した時に実行されるメソッド
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let comedianVC = storyboard?.instantiateViewController(withIdentifier: "Comedian") as! ComedianDetailViewController
        
        if comedianNameUniqueArray != [] {
            
            comedianVC.comedianId = comedianDataUniqueArray[indexPath.row]
            
            print("comedianVC.comedianID:\(comedianVC.comedianId)")
            
            //遷移を実行
            
            self.navigationController?.pushViewController(comedianVC, animated: true)
            collectionView.deselectItem(at: indexPath, animated: true)

        } else {
            
            return
            
        }
        
        //ログ
        AnalyticsUtil.sendAction(ActionEvent(screenName: .myReviewVC,
                                                     actionType: .tap,
                                             actionLabel: .template(ActionLabelTemplate.myPageCellTap)))

    }
    
}
