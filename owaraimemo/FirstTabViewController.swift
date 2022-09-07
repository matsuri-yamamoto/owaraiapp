//
//  FirstTabViewController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/06/21.
//

import UIKit
import Firebase
import FirebaseFirestore

class FirstTabViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var comedianIdArray1: [String] = ["にぼしいわし_1","トルクレンチガールズ_1","シマウマフック_1","ガーベラガーデン_1","牛女_1","ボニーボニー_1"]
    var comedianIdArray2: [String] = ["ビッグボンバーズ_1","アオイサカナ_1","ヤング_1","まんたナイスミドル_1","鳥山明・暗_1","魚雷2倍速_1"]
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "みつかる"
        
        //fetchDataなどで分割した配列の各データを呼び、配列を結合する→cellItemAtにてindexPathでセットする
        
        cellComedianNameData()
        cellScoreData()
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        hidesBottomBarWhenPushed = true
        
        //pvログ
        AnalyticsUtil.sendScreenName(ScreenEvent(screenName: .firstTabVC))
        
    }
    
    
    
    func cellComedianNameData() {
        
        //comedianIdArray1~3に紐づく芸人名を一つずつ呼び出して、順にcomedianNameArrayにappendする
        //1つ目のArrayの芸人名をセットする
        self.db.collection("comedian").whereField(FieldPath.documentID(), in: self.comedianIdArray1).whereField("delete_flag", isEqualTo: "false").getDocuments() { (querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                for document in querySnapshot!.documents {
                    
                    print("data:\(document.data())")
                    let comedianName = document.get("for_list_name") as! String
                    self.comedianNameArray1.append(comedianName)
                    
                    let comedianId = document.documentID
                    self.comedianNameArrayId1.append(comedianId)
                    
                    let comedianCopyRight = document.get("copyright_flag") as! String
                    self.comedianCopyRightArray1.append(comedianCopyRight)
                    
                    
                }
                //※forinの外で処理しないと、データの数分の回数処理が行われてしまう
                print("comedianNameArray1(初回):\(self.comedianNameArray1)")
                self.comedianNameArray.append(contentsOf: self.comedianNameArray1)
                print("comedianNameArray(初回):\(self.comedianNameArray)")
                self.comedianNameArrayId.append(contentsOf: self.comedianNameArrayId1)
                
                self.comedianCopyRightArray.append(contentsOf: self.comedianCopyRightArray1)
                
                
                
                
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
                            
                            
                            
                        }
                        
                        self.comedianNameArray.append(contentsOf: self.comedianNameArray2)
                        print("comedianNameArray2(初回):\(self.comedianNameArray2)")
                        self.comedianNameArrayId.append(contentsOf: self.comedianNameArrayId2)
                        
                        self.comedianCopyRightArray.append(contentsOf: self.comedianCopyRightArray2)
                        
                        
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
                                        
                                                                                
                                    }
                                    
                                    print("comedianNameArray3(初回):\(self.comedianNameArray3)")
                                    self.comedianNameArray.append(contentsOf: self.comedianNameArray3)
                                    print("comedianNameArray(2回目):\(self.comedianNameArray)")
                                    self.comedianNameArrayId.append(contentsOf: self.comedianNameArrayId3)
                                    
                                    self.comedianCopyRightArray.append(contentsOf: self.comedianCopyRightArray3)
                                    
                                    self.collectionView.reloadData()
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    
    func cellScoreData () {
        
        //comedianIdArray1~3に紐づくreviewのscoreを呼び出して、comedianごとのレビュー数とスコア平均を順にcomedianScoreArrayにappendする
        
        for comedianId in comedianIdArray1 {
            
            db.collection("review").whereField("comedian_id", isEqualTo: comedianId).getDocuments() {(querySnapshot, err) in
                
                if let err = err {
                    print("Error getting documents: \(err)")
                    return
                    
                } else {
                    
                    //特定のcomedianIdのスコアの配列を作る
                    var scoreArray:[Float] = []
                    
                    for document in querySnapshot!.documents {
                        
                        let documentId :String? = document.documentID
                        
                        if documentId != nil {
                            
                            let score = document.get("score") as! Float
                            scoreArray.append(score)
                            print("scoreArray:\(scoreArray)")
                            
                            //スコアの配列の平均値を追加する
                            self.comedianScoreArray.append(String(scoreArray.reduce(0, +) / Float(scoreArray.count)))
                            
                        } else {
                            
                            //ドキュメントが存在していなかったら、-をcomedianScoreArrayにセットする
                            self.comedianScoreArray.append("-")
                            
                        }
                        print("comedianScoreArray:\(self.comedianScoreArray)")
                    }
                }
            }
        }
    }
    
    
    
    //セクションの中のセルの数を返す
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        print("comedianNameArray.count:\(comedianNameArray.count)")
        return comedianNameArray.count
        
        
    }
    
    //セルのサイズを指定する処理
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // 横方向のスペース調整
        let horizontalSpace:CGFloat = 50
        
        //デバイスの横幅を2分割した横幅　- セル間のスペース*1（セル間のスペースが1列あるため）
        cellSize = (self.view.bounds.width - horizontalSpace*1)/2
        
        return CGSize(width: cellSize, height: cellSize*1.35)
        
    }
    
    
    
    //セルの中身を返す
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        //storyboard上のセルを生成　storyboardのIdentifierで付けたものをここで設定する
        let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        //芸人画像を指定する
        comedianImageView = cell.contentView.viewWithTag(1) as! UIImageView
        let comedianCopyrightFlag = comedianCopyRightArray[indexPath.row]
        
        if comedianCopyrightFlag == "true" {
            
            comedianImageView.image = UIImage(named: "\(comedianNameArrayId[indexPath.row])")
            
        }
        
        if comedianCopyrightFlag == "false" {
            
            comedianImageView.image = UIImage(named: "noImage")
            
        }
        
        
        
        
        //芸人名を設定する
        comedianNameLabel = cell.contentView.viewWithTag(2) as! UILabel
        
        print("cellcomedianNameArray:\(comedianNameArray)")
        
        comedianNameLabel.text = comedianNameArray[indexPath.row]
        
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
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let comedianVC = storyboard?.instantiateViewController(withIdentifier: "Comedian") as! ComedianDetailViewController
        
        comedianVC.comedianId = self.comedianNameArrayId[indexPath.row]
        self.comedianId = self.comedianNameArrayId[indexPath.row]
        self.navigationController?.pushViewController(comedianVC, animated: true)
        hidesBottomBarWhenPushed = true
        
        AnalyticsUtil.sendAction(ActionEvent(screenName: .firstTabVC,
                                             actionType: .tap,
                                             actionLabel: .template(ActionLabelTemplate.cellTap)))
        
        //        AnalyticsUtil.sendActionForFirstTabCellTap(ActionEventForFirstTabCellTap(screenName: .firstTabVC, actionType: .tap, actionLabel: .template(ActionLabelTemplate.cellTap)))
        
    }
    
    
}

