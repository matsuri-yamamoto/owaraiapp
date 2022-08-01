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
        
        
        if currentUser?.uid == nil {
            
            
                        
            //ログインしていない場合、ログイン推奨ページに遷移
            let recLoginVC = storyboard?.instantiateViewController(withIdentifier: "RecLogin") as! RecommendLoginViewController
            
            self.navigationController?.pushViewController(recLoginVC, animated: true)


            
            reviewButton.isHidden = true
            stockButton.isHidden = true
            
            
        } else {
            
        
            collectionView.delegate = self
            collectionView.dataSource = self

            title = "マイページ"
            
            //ナビゲーションバーのボタン設置
            settingButtonItem = UIBarButtonItem(title: "設定", style: .done, target: self, action: #selector(settingButtonPressed))
            self.navigationItem.rightBarButtonItem = settingButtonItem
            
            navigationController?.navigationItem.leftBarButtonItem?.customView?.isHidden = true
            
            self.tabBarController?.tabBar.isHidden = false
            
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

            
            
            db.collection("review").whereField("user_id", isEqualTo: Auth.auth().currentUser?.uid).getDocuments() { [self] (querySnapshot, err) in
                if let err = err {
                            print("Error getting documents: \(err)")
                            return
                } else {
            
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        
                        //自分のレビューデータのcomedian_nameを配列に格納する
                        self.comedianNameArray.append(document.data()["comedian_display_name"] as! String)
                        print("comedianNameArray: \(self.comedianNameArray)")


                        //自分のレビューデータのcomedian_idを配列に格納する
                        self.comedianDataArray.append(document.data()["comedian_id"] as! String)
                        print("comedianDataArray: \(self.comedianDataArray)")

                        
                        //comedian_nameの値をユニークにする
                        var setName = Set<String>()
                        self.comedianNameUniqueArray = self.comedianNameArray.filter { setName.insert($0).inserted }
                        print("comedianUniqueArray: \(self.comedianNameUniqueArray)")
                        
                        //comedian_idの値をユニークにする
                        var setData = Set<String>()
                        self.comedianDataUniqueArray = self.comedianDataArray.filter { setData.insert($0).inserted }
                        print("comedianUniqueArray: \(self.comedianDataUniqueArray)")
                                            
                    }
                    collectionView.reloadData()
                }
            }
        }
    }
                
        
    override func viewDidAppear(_ animated: Bool) {
        //ReviewVCに渡す用のComedianDataを取得する(対象となる芸人はComedianNameArrayと同じだが、ComedianData型である必要があるため)
        //毎回データ更新してくれるように、viewDidAppearの中に記述する
        if comedianNameUniqueArray != [] {
            

        }
    }
    
    
    @IBAction func reviewButton(_ sender: Any) {
        
        //comedianNameArrayとcomedianDataArrayの配列から一旦stockのデータを消す
        comedianNameArray = []
        comedianDataArray = []
        
        //レビューデータを配列にセットする
        db.collection("review").whereField("user_id", isEqualTo: Auth.auth().currentUser?.uid).getDocuments() { [self] (querySnapshot, err) in
            if let err = err {
                        print("Error getting documents: \(err)")
                        return
            } else {
        
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    //自分のレビューデータのcomedian_nameを配列に格納する
                    self.comedianNameArray.append(document.data()["comedian_display_name"] as! String)
                    print("comedianNameArray: \(self.comedianNameArray)")


                    //自分のレビューデータのcomedian_idを配列に格納する
                    self.comedianDataArray.append(document.data()["comedian_id"] as! String)
                    print("comedianDataArray: \(self.comedianDataArray)")

                    
                    //comedian_nameの値をユニークにする
                    var setName = Set<String>()
                    self.comedianNameUniqueArray = self.comedianNameArray.filter { setName.insert($0).inserted }
                    print("comedianUniqueArray: \(self.comedianNameUniqueArray)")
                    
                    //comedian_idの値をユニークにする
                    var setData = Set<String>()
                    self.comedianDataUniqueArray = self.comedianDataArray.filter { setData.insert($0).inserted }
                    print("comedianUniqueArray: \(self.comedianDataUniqueArray)")
                                        
                }
                collectionView.reloadData()
            }
        }
        
        
        
    }
    
    
    @IBAction func stockButton(_ sender: Any) {
        
        //comedianNameArrayとcomedianDataArrayの配列から一旦reviewのデータを消す
        comedianNameArray = []
        comedianDataArray = []
                
        //ストックデータを配列にセットする
        db.collection("stock").whereField("user_id", isEqualTo: Auth.auth().currentUser?.uid).getDocuments() { [self] (querySnapshot, err) in
            if let err = err {
                        print("Error getting documents: \(err)")
                        return
            } else {
                
        
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    
                    
                    //自分のレビューデータのcomedian_nameを配列に格納する
                    self.comedianNameArray.append(document.data()["comedian_display_name"] as! String)
                    print("comedianNameArray: \(self.comedianNameArray)")

                    //自分のレビューデータのcomedian_idを配列に格納する
                    self.comedianDataArray.append(document.data()["comedian_id"] as! String)
                    print("comedianDataArray: \(self.comedianDataArray)")
                    
                    //comedian_nameの値をユニークにする
                    var setName = Set<String>()
                    self.comedianNameUniqueArray = self.comedianNameArray.filter { setName.insert($0).inserted }
                    print("comedianUniqueArray: \(self.comedianNameUniqueArray)")
                    
                    //comedian_idの値をユニークにする
                    var setData = Set<String>()
                    self.comedianDataUniqueArray = self.comedianDataArray.filter { setData.insert($0).inserted }
                    print("comedianUniqueArray: \(self.comedianDataUniqueArray)")
                                        
                }
                collectionView.reloadData()
            }
        }
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
        let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        //芸人画像を指定する
        comedianImageView = cell.contentView.viewWithTag(1) as! UIImageView
        comedianImageView.image = UIImage(named: "\(comedianDataUniqueArray[indexPath.row])")
        
        //芸人名を設定する
        comedianNameLabel = cell.contentView.viewWithTag(2) as! UILabel
        comedianNameLabel.text = comedianNameUniqueArray[indexPath.row]
        
        return cell
    }
    
    //セルのサイズを指定する処理
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        // 横方向のスペース調整
        let horizontalSpace:CGFloat = 50

        //デバイスの横幅を2分割した横幅　- セル間のスペース*1（セル間のスペースが1列あるため）
        cellSize = (self.view.bounds.width - horizontalSpace*1)/2

        return CGSize(width: cellSize, height: cellSize*1.35)

    }
    

    // 各セルを選択した時に実行されるメソッド
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let reviewVC = storyboard?.instantiateViewController(withIdentifier: "Review") as! ReviewViewController
        let nav = UINavigationController(rootViewController: reviewVC)
        
        if comedianNameUniqueArray != [] {
            
            reviewVC.comedianName = comedianNameUniqueArray[indexPath.row]
            reviewVC.comedianID = comedianDataUniqueArray[indexPath.row]
            
            print("reviewVC.comedianID:\(reviewVC.comedianID)")
            
            //遷移を実行
            self.present(nav, animated: true, completion: nil)
            collectionView.deselectItem(at: indexPath, animated: true)

        } else {
            
            return
            
        }
    }
    
}
