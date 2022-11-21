
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage


class ThirdTabViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let currentUser = Auth.auth().currentUser

    var comedianIdArray1: [String] = []
    var comedianIdArray2: [String] = []
    var comedianIdArray3: [String] = []
    
    
    var comedianNameArrayId1: [String] = []
    var comedianNameArrayId2: [String] = []
    var comedianNameArrayId3: [String] = []
    var comedianNameArrayId: [String] = []
    
    
    var comedianNameArray1: [String] = []
    var comedianNameArray2: [String] = []
    var comedianNameArray3: [String] = []
    var comedianNameArray: [String] = []
    
    var comedianCopyRightArray1: [String] = []
    var comedianCopyRightArray2: [String] = []
    var comedianCopyRightArray3: [String] = []
    var comedianCopyRightArray: [String] = []
    
    var comedianReferenceNameArray1: [String] = []
    var comedianReferenceNameArray2: [String] = []
    var comedianReferenceNameArray3: [String] = []
    var comedianReferenceNameArray: [String] = []
    
    var comedianReferenceUrlArray1: [String] = []
    var comedianReferenceUrlArray2: [String] = []
    var comedianReferenceUrlArray3: [String] = []
    var comedianReferenceUrlArray: [String] = []

    
    var comedianReviewCountArray: [String] = []
    var comedianScoreArray: [String] = []
    
    
    var cellSize :CGFloat = 0
    
    var comedianImageView = UIImageView()
    var cellNumber = Int()
    var comedianNameLabel = UILabel()
    var comedianReviewLabel = UILabel()
    var comedianScoreLabel = UILabel()
    var comedianStockLabel = UILabel()
    
    //ログのための変数
    var comedianId :String = ""

    
    let db = Firestore.firestore()
    //画像のパス
    let storage = Storage.storage(url:"gs://owaraiapp-f80fd.appspot.com").reference()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //fetchDataなどで分割した配列の各データを呼び、配列を結合する→cellItemAtにてindexPathでセットする
        
        cellComedianNameData()
        //        cellScoreData()
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //セルを指定
        collectionView.register(UINib(nibName: "TabViewCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TabViewCollectionViewCell")
        
        //セルのサイズを指定
        let layout = UICollectionViewFlowLayout()
        // 横方向のスペース調整
        let horizontalSpace:CGFloat = 20
        //デバイスの横幅を3分割した横幅　- セル間のスペース*1（セル間のスペースが1列あるため）
        cellSize = (self.view.bounds.width - horizontalSpace*2)/3

        print("firstTabcellSize:\(cellSize)")
        
        
        
        layout.itemSize = CGSize(width: cellSize, height: cellSize*1.45)
        collectionView.collectionViewLayout = layout
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        //pvログ
        AnalyticsUtil.sendScreenName(ScreenEvent(screenName: .thirdTabVC))
        
        if self.currentUser?.uid != "Wsp1fLJUadXIZEiwvpuPWvhEjNW2"
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
                "page": "ThirdTab",
                "action_type": "pv",
                "tapped_comedian_id": "",
                "tapped_user_id": "",
                "create_datetime": FieldValue.serverTimestamp(),
                "update_datetime": FieldValue.serverTimestamp(),
                "delete_flag": false,
                "delete_datetime": nil,
            ] as [String : Any]
            logRef.setData(logDic)
                        
        }

        
    }
    
    
    
    func cellComedianNameData() {
        
        //Arrayにcomedian_idをセットする
        self.db.collection("third_tab_comedian_array").getDocuments() { (querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                for document in querySnapshot!.documents {
                    
                    var comedianIdArray1 :[String] = []
                    var comedianIdArray2 :[String] = []
                    var comedianIdArray3 :[String] = []
                    
                    comedianIdArray1 = document.get("array1") as! [String]
                    self.comedianIdArray1.append(contentsOf: comedianIdArray1)
                    
                    comedianIdArray2 = document.get("array2") as! [String]
                    self.comedianIdArray2.append(contentsOf: comedianIdArray2)
                    
                    comedianIdArray3 = document.get("array3") as! [String]
                    self.comedianIdArray3.append(contentsOf: comedianIdArray3)
                    
                    
                    
                }
                
                //comedianIdArray1~3に紐づく芸人名を一つずつ呼び出して、順にcomedianNameArrayにappendする
                //1つ目のArrayの芸人名をセットする
                self.db.collection("comedian").whereField(FieldPath.documentID(), in: self.comedianIdArray1).whereField("delete_flag", isEqualTo: "false").getDocuments() { (querySnapshot, err) in
                    
                    if let err = err {
                        print("Error getting documents: \(err)")
                        return
                        
                    } else {
                        for document in querySnapshot!.documents {
                            
                            let comedianName = document.get("for_list_name") as! String
                            self.comedianNameArray1.append(comedianName)
                            
                            let comedianId = document.documentID
                            self.comedianNameArrayId1.append(comedianId)
                            
                            let comedianCopyRight = document.get("copyright_flag") as! String
                            self.comedianCopyRightArray1.append(comedianCopyRight)
                            
                            let comedianReferenceName = document.get("reference_name") as! String
                            self.comedianReferenceNameArray1.append(comedianReferenceName)
                            
                            let comedianReferenceUrl = document.get("reference_url") as! String
                            self.comedianReferenceUrlArray1.append(comedianReferenceUrl)
                            
                        }
                        //※forinの外で処理しないと、データの数分の回数処理が行われてしまう
                        print("comedianNameArray1(初回):\(self.comedianNameArray1)")
                        self.comedianNameArray.append(contentsOf: self.comedianNameArray1)
                        print("comedianNameArray(初回):\(self.comedianNameArray)")
                        self.comedianNameArrayId.append(contentsOf: self.comedianNameArrayId1)
                        
                        self.comedianCopyRightArray.append(contentsOf: self.comedianCopyRightArray1)
                        
                        self.comedianReferenceNameArray.append(contentsOf: self.comedianReferenceNameArray1)
                        self.comedianReferenceUrlArray.append(contentsOf: self.comedianReferenceUrlArray1)
                        
                        //2つ目のArrayの芸人名をセットする
                        self.db.collection("comedian").whereField(FieldPath.documentID(), in: self.comedianIdArray2).whereField("delete_flag", isEqualTo: "false").getDocuments() { (querySnapshot, err) in
                            
                            if let err = err {
                                print("Error getting documents: \(err)")
                                return
                                
                            } else {
                                for document in querySnapshot!.documents {
                                    
                                    let comedianName = document.get("for_list_name") as! String
                                    self.comedianNameArray2.append(comedianName)
                                    
                                    let comedianId = document.documentID
                                    self.comedianNameArrayId2.append(comedianId)
                                    
                                    let comedianCopyRight = document.get("copyright_flag") as! String
                                    self.comedianCopyRightArray2.append(comedianCopyRight)
                                    
                                    let comedianReferenceName = document.get("reference_name") as! String
                                    self.comedianReferenceNameArray2.append(comedianReferenceName)
                                    
                                    let comedianReferenceUrl = document.get("reference_url") as! String
                                    self.comedianReferenceUrlArray2.append(comedianReferenceUrl)

                                    
                                    
                                }
                                
                                self.comedianNameArray.append(contentsOf: self.comedianNameArray2)
                                print("comedianNameArray2(初回):\(self.comedianNameArray2)")
                                self.comedianNameArrayId.append(contentsOf: self.comedianNameArrayId2)
                                
                                self.comedianCopyRightArray.append(contentsOf: self.comedianCopyRightArray2)
                                
                                self.comedianReferenceNameArray.append(contentsOf: self.comedianReferenceNameArray2)
                                self.comedianReferenceUrlArray.append(contentsOf: self.comedianReferenceUrlArray2)

                                
                                if self.comedianIdArray3 == [] {
                                    
                                    self.collectionView.reloadData()
                                    
                                    
                                } else {
                                    
                                    //3つ目のArrayの芸人名をセットする
                                    self.db.collection("comedian").whereField(FieldPath.documentID(), in: self.comedianIdArray3).whereField("delete_flag", isEqualTo: "false").getDocuments() {(querySnapshot, err) in
                                        
                                        if let err = err {
                                            print("Error getting documents: \(err)")
                                            return
                                            
                                        } else {
                                            
                                            for document in querySnapshot!.documents {
                                                
                                                let comedianName = document.get("for_list_name") as! String
                                                self.comedianNameArray3.append(comedianName)
                                                
                                                let comedianId = document.documentID
                                                self.comedianNameArrayId3.append(comedianId)
                                                
                                                let comedianCopyRight = document.get("copyright_flag") as! String
                                                self.comedianCopyRightArray3.append(comedianCopyRight)
                                                
                                                let comedianReferenceName = document.get("reference_name") as! String
                                                self.comedianReferenceNameArray3.append(comedianReferenceName)
                                                
                                                let comedianReferenceUrl = document.get("reference_url") as! String
                                                self.comedianReferenceUrlArray3.append(comedianReferenceUrl)

                                                
                                                
                                                
                                            }
                                            
                                            print("comedianNameArray3(初回):\(self.comedianNameArray3)")
                                            self.comedianNameArray.append(contentsOf: self.comedianNameArray3)
                                            print("comedianNameArray(2回目):\(self.comedianNameArray)")
                                            self.comedianNameArrayId.append(contentsOf: self.comedianNameArrayId3)
                                            
                                            self.comedianCopyRightArray.append(contentsOf: self.comedianCopyRightArray3)

                                            self.comedianReferenceNameArray.append(contentsOf: self.comedianReferenceNameArray3)
                                            self.comedianReferenceUrlArray.append(contentsOf: self.comedianReferenceUrlArray3)

                                            print("comedianNameArrayId:\(self.comedianNameArrayId)")
                                            print("comedianCopyRightArray:\(self.comedianCopyRightArray)")

                                            
                                            self.collectionView.reloadData()
                                            
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
    
    
    //    func cellScoreData () {
    //
    //        //comedianIdArray1~3に紐づくreviewのscoreを呼び出して、comedianごとのレビュー数とスコア平均を順にcomedianScoreArrayにappendする
    //
    //        for comedianId in comedianIdArray1 {
    //
    //            db.collection("review").whereField("comedian_id", isEqualTo: comedianId).getDocuments() {(querySnapshot, err) in
    //
    //                if let err = err {
    //                    print("Error getting documents: \(err)")
    //                    return
    //
    //                } else {
    //
    //                    //特定のcomedianIdのスコアの配列を作る
    //                    var scoreArray:[Float] = []
    //
    //                    for document in querySnapshot!.documents {
    //
    //                        let documentId :String? = document.documentID
    //
    //                        if documentId != nil {
    //
    //                            let score = document.get("score") as! Float
    //                            scoreArray.append(score)
    //                            print("scoreArray:\(scoreArray)")
    //
    //                            //スコアの配列の平均値を追加する
    //                            self.comedianScoreArray.append(String(scoreArray.reduce(0, +) / Float(scoreArray.count)))
    //
    //                        } else {
    //
    //                            //ドキュメントが存在していなかったら、-をcomedianScoreArrayにセットする
    //                            self.comedianScoreArray.append("-")
    //
    //                        }
    //                        print("comedianScoreArray:\(self.comedianScoreArray)")
    //                    }
    //                }
    //            }
    //        }
    //    }
    
    
    
    //セクションの中のセルの数を返す
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        print("comedianNameArray.count:\(comedianNameArray.count)")
        return comedianNameArray.count
        
        
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
    
    
    
    //セルの中身を返す
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        //storyboard上のセルを生成　storyboardのIdentifierで付けたものをここで設定する
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TabViewCollectionViewCell", for: indexPath) as! TabViewCollectionViewCell
        
        cell.rankingLabel.isHidden = true
        
        //芸人画像を指定する
        let comedianCopyrightFlag = comedianCopyRightArray[indexPath.row]
        
        if comedianCopyrightFlag == "true" {
            
            cell.comedianImageView.image = UIImage(named: "\(comedianNameArrayId[indexPath.row])")
            cell.comedianImageView.contentMode = .scaleAspectFill
            cell.comedianImageView.clipsToBounds = true
        
                
//            let imageRef = self.storage.child("comedian_image/\(comedianNameArrayId[indexPath.row]).jpg")
//            cell.comedianImageView.sd_setImage(with: imageRef, placeholderImage: UIImage(named: "noImage"))
//            cell.comedianImageView.contentMode = .scaleAspectFill
//            cell.comedianImageView.clipsToBounds = true
            
//            print("画像のパス：comedian_image/\(comedianNameArrayId[indexPath.row]).jpg")
            
        }
        
        if comedianCopyrightFlag == "false" {
            
            cell.comedianImageView.image = UIImage(named: "noImage")
            cell.comedianImageView.contentMode = .scaleAspectFill
            cell.comedianImageView.clipsToBounds = true
            
            
        }
        
        if comedianCopyrightFlag == "reference" {
        
            cell.referenceButton.tag = indexPath.row
            
            cell.comedianImageView.image = UIImage(named: "\(self.comedianNameArrayId[indexPath.row])")
            cell.comedianImageView.contentMode = .scaleAspectFill
            cell.comedianImageView.clipsToBounds = true
            
            cell.referenceButton.contentHorizontalAlignment = .left
            cell.referenceButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 6.0)
            cell.referenceButton.setTitle(self.comedianReferenceNameArray[indexPath.row], for: .normal)
            cell.referenceButton.addTarget(self, action: #selector(self.tappedReferenceButton(sender:)), for: .touchUpInside)
            
            
        }
        
        print("cellcomedianNameArray:\(comedianNameArray)")
        
        cell.comedianNameLabel.text = " " + comedianNameArray[indexPath.row]

        //レビュー数とレビューのツボった度の平均を設定する
        //        comedianReviewLabel = cell.contentView.viewWithTag(3) as! UILabel
        //        comedianScoreLabel = cell.contentView.viewWithTag(5) as! UILabel
        
        //        comedianReviewLabel.text = comedianReviewCountArray[indexPath.row]
        //        comedianScoreLabel.text = comedianScoreArray[indexPath.row]
        
        
        //        db.collection("review").whereField("comedian_id", isEqualTo: comedianIdArray[indexPath.row]).getDocuments() {(querySnapshot, err) in
        
        
        //        //あとでみる数を設定する
        //        comedianStockLabel = cell.contentView.viewWithTag(4) as! UILabel
        //
        //        db.collection("stock").whereField("comedian_id", isEqualTo: comedianIdArray[indexPath.row]).getDocuments() {(querySnapshot, err) in
        //
        //            if let err = err {
        //                print("Error getting documents: \(err)")
        //                return
        //
        //            } else {
        //                for document in querySnapshot!.documents {
        //
        //                    self.comedianStockLabel.text = String(document.data().count)
        //
        //                }
        //            }
        //        }
        
        return cell
        
    }
    
    @objc func tappedReferenceButton(sender: UIButton) {
        
        let buttonTag = sender.tag
        let tappedReferenceUrl = self.comedianReferenceUrlArray[buttonTag]
        
        let referenceVC = self.storyboard?.instantiateViewController(withIdentifier: "Reference") as! ReferenceViewController
        
        let referenceUrl = URL(string: "\(tappedReferenceUrl)")
        referenceVC.url = referenceUrl
        
        self.navigationController?.pushViewController(referenceVC, animated: true)
                
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let comedianVC = storyboard?.instantiateViewController(withIdentifier: "Comedian") as! ComedianDetailViewController
        
        comedianVC.comedianId = self.comedianNameArrayId[indexPath.row]
        self.comedianId = self.comedianNameArrayId[indexPath.row]
        self.navigationController?.pushViewController(comedianVC, animated: true)
        
        AnalyticsUtil.sendAction(ActionEvent(screenName: .thirdTabVC,
                                             actionType: .tap,
                                             actionLabel: .template(ActionLabelTemplate.cellTap)))
        
        if self.currentUser?.uid != "Wsp1fLJUadXIZEiwvpuPWvhEjNW2"
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
                "page": "ThirdTab",
                "action_type": "tap_comedian",
                "tapped_comedian_id": self.comedianId,
                "tapped_user_id": "",
                "create_datetime": FieldValue.serverTimestamp(),
                "update_datetime": FieldValue.serverTimestamp(),
                "delete_flag": false,
                "delete_datetime": nil,
            ] as [String : Any]
            logRef.setData(logDic)
                        
        }

        
        
    }
    
    
}
