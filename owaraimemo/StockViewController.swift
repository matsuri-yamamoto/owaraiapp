//
//  StockViewController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/10/05.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorageUI


class StockViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var comedianImageView = UIImageView()
    var comedianNameLabel = UILabel()
    
    var comedianNameArray: [String] = []
    var comedianNameUniqueArray: [String] = []

    var comedianDataArray: [String] = []
    var comedianDataUniqueArray: [String] = []

    
    var cellSize :CGFloat = 0
    
    //Firestoreを使うための下準備
    let currentUser = Auth.auth().currentUser
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
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
        
        dataRefresh()
        
        self.collectionView.refreshControl = UIRefreshControl()
        self.collectionView.refreshControl?.addTarget(self, action: #selector(dataRefresh), for: .valueChanged)

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //ReviewVCに渡す用のComedianDataを取得する(対象となる芸人はComedianNameArrayと同じだが、ComedianData型である必要があるため)
        //毎回データ更新してくれるように、viewDidAppearの中に記述する
        if comedianNameUniqueArray != [] {
            

        }
    
        //pvログ
        AnalyticsUtil.sendScreenName(ScreenEvent(screenName: .myReviewVC))
    }
    
    
    @objc func dataRefresh() {
        
        self.comedianNameArray = []
        self.comedianDataArray = []
        self.comedianNameUniqueArray = []
        self.comedianDataUniqueArray = []

        
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
                    }
                
                self.collectionView.reloadData()

            }
            
            self.collectionView.refreshControl?.endRefreshing()
            
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
