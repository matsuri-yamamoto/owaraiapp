//
//  ComedianDetailViewController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/06/02.
//

import UIKit
import FirebaseFirestore
import Firebase
import WebKit
import youtube_ios_player_helper
import SwiftUI

class ComedianDetailViewController: UIViewController, YTPlayerViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //comedian_idが渡される用の変数
    var comedianId: String = ""
    
    @IBOutlet weak var comedianNameLabel: UILabel!
    @IBOutlet weak var officeLabel: UILabel!
    @IBOutlet weak var startYearLabel: UILabel!
    @IBOutlet weak var comedianTypeLabel: UILabel!
    @IBOutlet weak var comedyTypeLabel1: UILabel!
    @IBOutlet weak var comedyTypeLabel2: UILabel!
    @IBOutlet weak var comedianImageView: UIImageView!
    @IBOutlet weak var scoreImageView: UIImageView!
    
    @IBOutlet weak var mediaButton1: UIButton!
    @IBOutlet weak var mediaButton2: UIButton!
    @IBOutlet weak var mediaButton3: UIButton!
    @IBOutlet weak var mediaButton4: UIButton!
    @IBOutlet weak var mediaButton5: UIButton!
    @IBOutlet weak var mediaButton6: UIButton!
    @IBOutlet weak var mediaButton7: UIButton!
    @IBOutlet weak var mediaButton8: UIButton!
    @IBOutlet weak var mediaButton9: UIButton!

    
    //レビュー・あとでみるボタンの画像を設定するための接続
    @IBOutlet weak var reviwButton: UIButton!
    @IBOutlet weak var stockButton: UIButton!
    //レビュー・あとでみるボタンの件数ラベルを設定するための接続
    @IBOutlet weak var reviewCountLabel: UILabel!
    @IBOutlet weak var stockCountLabel: UILabel!
    
    //あとでみるボタンのデフォルトと保存時の画像
    let defaltStockButtonImage = UIImage(named: "defaltStockButton")
    let existStockButtonImage = UIImage(named: "existStockButton")

    
    
    //URLを持つ各種メディアを格納する配列
    var mediaImageArray: [UIImage] = []
    
    //各種メディアのURLを格納する配列
    var mediaUrlArray: [String] = []
    
    //各種メディア用の画像
    let twitterImage = UIImage(named: "twitter")
    let youtubeImage = UIImage(named: "youtube")
    let podcastImage = UIImage(named: "podcast")
    let standfmImage = UIImage(named: "standfm")
    let geraImage = UIImage(named: "gera")
    let radiotalkImage = UIImage(named: "radiotalk")
    let spotifyImage = UIImage(named: "spotify")
    
    
    //ネタ動画用のView
    @IBOutlet weak var playerView1: YTPlayerView!
    @IBOutlet weak var playerView2: YTPlayerView!
    
    
    //reviewのtableViewにセットする配列
    var reviewIdArray: [String] = []
    var reviewUserNameArray: [String] = []
    var reviewUserIdArray: [String] = []
    var reviewCreatedArray: [String] = []
    var reviewScoreArray: [String] = []
    var reviewCommentArray: [String] = []

    //Firestoreを使うための下準備
    let currentUser = Auth.auth().currentUser
    let db = Firestore.firestore()
    
    

    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        print("comedian:\(comedianId)")
        
        //comedianドキュメントから各項目を参照
        db.collection("comedian").whereField(FieldPath.documentID(), isEqualTo: comedianId).getDocuments() {(querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    self.comedianNameLabel.text = document.data()["comedian_name"] as! String
                    self.officeLabel.text = document.data()["office_name"] as! String
                    self.startYearLabel.text = document.data()["start_year"] as! String + "結成"
                    self.comedianTypeLabel.text = document.data()["comedian_type"] as! String
                    self.comedyTypeLabel1.text = document.data()["comedy_type_1"] as! String
                    self.comedyTypeLabel2.text = document.data()["comedy_type_2"] as! String
                    self.comedianImageView.image = UIImage(named: "\(self.comedianId)")
                    self.view.addSubview(self.comedianImageView)
                    
                    //mediaArrayを作る
                    if document.data()["twitter_1"] != nil {
                        self.mediaImageArray.append(self.twitterImage!)
                    } else {
                      return
                    }
                    if document.data()["twitter_2"] != nil {
                        self.mediaImageArray.append(self.twitterImage!)
                    } else {
                        return
                      }
                    if document.data()["twitter_3"] != nil {
                        self.mediaImageArray.append(self.twitterImage!)
                    } else {
                        return
                      }
                    if document.data()["youtube_1"] != nil {
                        self.mediaImageArray.append(self.youtubeImage!)
                    } else {
                        return
                      }
                    if document.data()["podcast_1"] != nil {
                        self.mediaImageArray.append(self.podcastImage!)
                    } else {
                        return
                      }
                    if document.data()["standfm_1"] != nil {
                        self.mediaImageArray.append(self.standfmImage!)
                    } else {
                        return
                      }
                    if document.data()["gera_1"] != nil {
                        self.mediaImageArray.append(self.geraImage!)
                    } else {
                        return
                      }
                    if document.data()["radiotalk_1"] != nil {
                        self.mediaImageArray.append(self.radiotalkImage!)
                    } else {
                        return
                      }
                    if document.data()["spotify_1"] != nil {
                        self.mediaImageArray.append(self.spotifyImage!)
                    } else {
                        return
                      }
                    
                    
                    //mediaUrlArrayを作る
                    if document.data()["twitter_1"] != nil {
                        self.mediaUrlArray.append(document.data()["twitter_1"] as! String)
                    }
                    if document.data()["twitter_2"] != nil {
                        self.mediaUrlArray.append(document.data()["twitter_2"] as! String)
                    }
                    if document.data()["twitter_3"] != nil {
                        self.mediaUrlArray.append(document.data()["twitter_3"] as! String)
                    }
                    if document.data()["youtube_1"] != nil {
                        self.mediaUrlArray.append(document.data()["youtube_1"] as! String)
                    }
                    if document.data()["podcast_1"] != nil {
                        self.mediaUrlArray.append(document.data()["podcast_1"] as! String)
                    }
                    if document.data()["standfm_1"] != nil {
                        self.mediaUrlArray.append(document.data()["standfm_1"] as! String)
                    }
                    if document.data()["gera_1"] != nil {
                        self.mediaUrlArray.append(document.data()["gera_1"] as! String)
                    }
                    if document.data()["radiotalk_1"] != nil {
                        self.mediaUrlArray.append(document.data()["radiotalk_1"] as! String)
                    }
                    if document.data()["spotify_1"] != nil {
                        self.mediaUrlArray.append(document.data()["spotify_1"] as! String)
                    }
                    
                    //配列のn番目のインデックスが存在していたら、画像をセットしボタンを有効化する
                    //そうでなければボタンを非表示
                    if self.mediaImageArray.indices.contains(0) == true {
                        
                        //mediaInamgeArrayの該当indexの画像をセット
                        self.mediaButton1.setImage(self.mediaImageArray[0], for: .normal)
                        //タップでmediaUrlArrayの該当indexのurlに遷移するメソッド
                        self.mediaButton1.addTarget(self, action: #selector(self.mb1Tapped(_ :)), for: .touchUpInside)
                        
                    } else {
                        self.mediaButton1.isHidden = true
                    }
                    
                    if self.mediaImageArray.indices.contains(1) == true {
                        
                        //mediaInamgeArrayの該当indexの画像をセット
                        self.mediaButton2.setImage(self.mediaImageArray[1], for: .normal)
                        //タップでmediaUrlArrayの該当indexのurlに遷移するメソッド
                        self.mediaButton2.addTarget(self, action: #selector(self.mb2Tapped(_ :)), for: .touchUpInside)
                        
                    } else {
                        self.mediaButton2.isHidden = true
                    }
                    
                    if self.mediaImageArray.indices.contains(2) == true {
                        
                        //mediaInamgeArrayの該当indexの画像をセット
                        self.mediaButton3.setImage(self.mediaImageArray[2], for: .normal)
                        //タップでmediaUrlArrayの該当indexのurlに遷移するメソッド
                        self.mediaButton3.addTarget(self, action: #selector(self.mb3Tapped(_ :)), for: .touchUpInside)
                        
                    } else {
                        self.mediaButton3.isHidden = true
                    }
                    
                    if self.mediaImageArray.indices.contains(3) == true {
                        
                        //mediaInamgeArrayの該当indexの画像をセット
                        self.mediaButton4.setImage(self.mediaImageArray[3], for: .normal)
                        //タップでmediaUrlArrayの該当indexのurlに遷移するメソッド
                        self.mediaButton4.addTarget(self, action: #selector(self.mb4Tapped(_ :)), for: .touchUpInside)
                        
                    } else {
                        self.mediaButton4.isHidden = true
                    }
                    
                    if self.mediaImageArray.indices.contains(4) == true {
                        
                        //mediaInamgeArrayの該当indexの画像をセット
                        self.mediaButton5.setImage(self.mediaImageArray[4], for: .normal)
                        //タップでmediaUrlArrayの該当indexのurlに遷移するメソッド
                        self.mediaButton5.addTarget(self, action: #selector(self.mb5Tapped(_ :)), for: .touchUpInside)
                        
                    } else {
                        self.mediaButton5.isHidden = true
                    }
                    
                    if self.mediaImageArray.indices.contains(5) == true {
                        
                        //mediaInamgeArrayの該当indexの画像をセット
                        self.mediaButton6.setImage(self.mediaImageArray[5], for: .normal)
                        //タップでmediaUrlArrayの該当indexのurlに遷移するメソッド
                        self.mediaButton6.addTarget(self, action: #selector(self.mb6Tapped(_ :)), for: .touchUpInside)
                        
                    } else {
                        self.mediaButton6.isHidden = true
                    }
                    
                    if self.mediaImageArray.indices.contains(6) == true {
                        
                        //mediaInamgeArrayの該当indexの画像をセット
                        self.mediaButton7.setImage(self.mediaImageArray[6], for: .normal)
                        //タップでmediaUrlArrayの該当indexのurlに遷移するメソッド
                        self.mediaButton7.addTarget(self, action: #selector(self.mb7Tapped(_ :)), for: .touchUpInside)
                        
                    } else {
                        self.mediaButton7.isHidden = true
                    }
                    
                    if self.mediaImageArray.indices.contains(7) == true {
                        
                        //mediaInamgeArrayの該当indexの画像をセット
                        self.mediaButton8.setImage(self.mediaImageArray[7], for: .normal)
                        //タップでmediaUrlArrayの該当indexのurlに遷移するメソッド
                        self.mediaButton8.addTarget(self, action: #selector(self.mb8Tapped(_ :)), for: .touchUpInside)
                        
                    } else {
                        self.mediaButton8.isHidden = true
                    }
                    
                    if self.mediaImageArray.indices.contains(8) == true {
                        
                        //mediaInamgeArrayの該当indexの画像をセット
                        self.mediaButton9.setImage(self.mediaImageArray[8], for: .normal)
                        //タップでmediaUrlArrayの該当indexのurlに遷移するメソッド
                        self.mediaButton9.addTarget(self, action: #selector(self.mb9Tapped(_ :)), for: .touchUpInside)
                        
                    } else {
                        self.mediaButton9.isHidden = true
                    }
                    
                }
            }
        }
        
        //reviewドキュメントからscoreを参照
        //reviewのtableViewにセットする配列を作る

        db.collection("review").whereField("comedian_id", isEqualTo: comedianId).order(by: "create_datetime").getDocuments() {(querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                for document in querySnapshot!.documents {
                    
                    //平均スコアを算出し、画像を設定
                    var scoreArray:[Float] = []
                    scoreArray.append(document.data()["score"] as! Float)
                    var averageScore = scoreArray.reduce(0, +) / Float(scoreArray.count)
                    
                    if averageScore == nil {
                        self.scoreImageView.image = UIImage(named: "noScored")
                    } else {
                        self.scoreImageView.image = UIImage(named: "score_\(averageScore)")
                    }
                    
                    //レビューボタンの件数ラベルを設定
                    self.reviewCountLabel.text = scoreArray.count as! String
                    
                    //以下、reviewのtableViewにセットする配列
                    self.reviewIdArray.append(document.documentID)
                    self.reviewUserIdArray.append(document.data()["user_id"] as! String)
                    self.reviewCreatedArray.append(document.data()["create_datetime"] as! String)
                    self.reviewScoreArray.append(document.data()["score"] as! String)
                    self.reviewCommentArray.append(document.data()["comment"] as! String)
                    
                }
            }
        }
        
        //レビューボタンの画像を設定
        let reviewButtonImage = UIImage(named: "reviewButton")
        reviwButton.setImage(reviewButtonImage, for: .normal)
                
        
        //user_id=currentUserかつcomedian_id=comedianIdのstockがあれば、あとでみるボタンに保存済みの画像を設定
        //なければ保存前の画像に設定
        
        var documentID :String?
        
        db.collection("stock").whereField("comedian_id", isEqualTo: comedianId).whereField("user_id", isEqualTo: Auth.auth().currentUser?.uid).whereField("valid_flag", isEqualTo: true).getDocuments() { [self](querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                for document in querySnapshot!.documents {
                    documentID = document.documentID
                }
                
                //ドキュメントidがnilの場合、該当のあとでみるがないということなのでその場合の画像を設定
                if documentID == nil {
                    self.stockButton.setImage(self.defaltStockButtonImage, for: .normal)
                    
                } else {
                    //nilでない場合、すでにstockが存在している場合の画像を設定
                    self.stockButton.setImage(self.existStockButtonImage, for: .normal)
                                        
                }
            }
        }

            
        //あとでみるボタンの件数ラベルを設定する
        db.collection("stock").whereField("comedian_id", isEqualTo: comedianId).whereField("valid_flag", isEqualTo: true).getDocuments() {(querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                for document in querySnapshot!.documents {
                    
                    var stockArray:[String] = []
                    stockArray.append(document.data()["user_id"] as! String)
                    
                }
            }
        }
        
        //動画を埋め込み
        //参考：https://dev.classmethod.jp/articles/youtube-player-ios-helper/
        self.playerView1.delegate = self;
        self.playerView1.load(withVideoId: "flxXhcds6tw", playerVars: ["playsinline":1])

        
        //2つ目の動画の下にtableViewを設置
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: self.playerView2.bottomAnchor, constant: 30.0)
//        tableView.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
//        tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
//        tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
//        tableView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // カスタムセルを登録する
        let nib = UINib(nibName: "ComedianReviewTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        
    }

    
    //各メディアボタンタップでmediaUrlArrayの該当indexのurlに遷移するメソッド
    @objc func mb1Tapped(_ sender: UIButton) {
        let url = URL(string: "\(self.mediaUrlArray[0])")
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!)
        }
    }
    
    @objc func mb2Tapped(_ sender: UIButton) {
        let url = URL(string: "\(self.mediaUrlArray[1])")
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!)
        }
    }
    
    @objc func mb3Tapped(_ sender: UIButton) {
        let url = URL(string: "\(self.mediaUrlArray[2])")
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!)
        }
    }
    
    @objc func mb4Tapped(_ sender: UIButton) {
        let url = URL(string: "\(self.mediaUrlArray[3])")
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!)
        }
    }
    
    @objc func mb5Tapped(_ sender: UIButton) {
        let url = URL(string: "\(self.mediaUrlArray[4])")
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!)
        }
    }
    
    @objc func mb6Tapped(_ sender: UIButton) {
        let url = URL(string: "\(self.mediaUrlArray[5])")
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!)
        }
    }
    
    @objc func mb7Tapped(_ sender: UIButton) {
        let url = URL(string: "\(self.mediaUrlArray[6])")
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!)
        }
    }
    
    @objc func mb8Tapped(_ sender: UIButton) {
        let url = URL(string: "\(self.mediaUrlArray[7])")
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!)
        }
    }
    
    @objc func mb9Tapped(_ sender: UIButton) {
        let url = URL(string: "\(self.mediaUrlArray[8])")
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!)
        }
    }
    
    
    @IBAction func reviewButton(_ sender: Any) {
        
        //レビュー画面に遷移
        let reviewVC = storyboard?.instantiateViewController(withIdentifier: "Review") as! ReviewViewController
        let nav = UINavigationController(rootViewController: reviewVC)

        //comedian_idを渡す
        reviewVC.comedianID = self.comedianId
        
        //comedianNameLabelをStringに変換して芸人名を渡す
        var comedianName = comedianNameLabel.text! as String
        reviewVC.comedianName = comedianName
        
        self.present(nav, animated: true, completion: nil)

    }
    
    @IBAction func stockButton(_ sender: Any) {
        
        //user_id=currentUserかつcomedian_id=comedianIdstockがなければtrueでレコード作り、画像を保存済みに更新する
        //あれば、flagを確認しtrueだったらfalseに、falseだったらtrueに更新する
        //flagがtrueだったら画像をデフォルトに、falseだったら保存済みの画像に更新する
        
        //すでにuser_id=currentUserかつcomedian_id=comedianIdかつtrueのstockがあれば、flagをfalseにする
        //画像を保存前の画像に戻す
        
        
        var documentID :String?
        var validFlag :Bool?
        
        db.collection("stock").whereField("comedian_id", isEqualTo: comedianId).whereField("user_id", isEqualTo: Auth.auth().currentUser?.uid).getDocuments() {(querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                for document in querySnapshot!.documents {
                    documentID = document.documentID
                    validFlag = document.data()["valid_flag"] as! Bool
                }
                
                //ドキュメントidがnilの場合、trueでレコードを作り画像を保存済みに更新する
                if documentID == nil {
                    //レコード保存
                    let stockRef = Firestore.firestore().collection("stock").document()
                    let stockDic = [
                        "user_id": Auth.auth().currentUser?.uid,
                        "comedian_id": self.comedianId,
                        "valid_flag": true,
                        "create_datetime": FieldValue.serverTimestamp(),
                        "update_datetime": FieldValue.serverTimestamp(),
                        "delete_flag": false,
                        "delete_datetime": nil,
                    ] as [String : Any?]
                                        
                    self.stockButton.setImage(self.existStockButtonImage, for: .normal)
                    
                } else {
                    
                    //nilでない場合、flagを確認
                    //flag=falseの場合、trueに更新
                    if validFlag == false {
                        
                        let existStockRef = Firestore.firestore().collection("stock").document(documentID!)
                        existStockRef.updateData([
                            "valid_flag": true,
                            "update_datetime": FieldValue.serverTimestamp(),
                        ])
                        self.stockButton.setImage(self.existStockButtonImage, for: .normal)
                        
                    } else {
                        
                        let existStockRef = Firestore.firestore().collection("stock").document(documentID!)
                        existStockRef.updateData([
                            "valid_flag": false,
                            "update_datetime": FieldValue.serverTimestamp(),
                        ])
                        self.stockButton.setImage(self.defaltStockButtonImage, for: .normal)
                        
                    }
                    
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ComedianReviewTableViewCell
        
        //レビューしたユーザーのユーザーIDを入れる変数
        var reviewUserId :String = ""
        //レビューについたいいねの件数を入れる配列
        var niceReviewArray :[String] = []
        
        //※プロフィール画像とニックネームの仕様が決まったらここに追加する(reviewUserIdArryがあるのでそれを使う)
        db.collection("user").whereField("uid", isEqualTo: self.reviewUserIdArray[indexPath.row]).getDocuments() {(querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    return

                } else {
                    for document in querySnapshot!.documents {
                        reviewUserId = document.data()["displayName"] as! String
                        cell.userIdLabel.text = reviewUserId

                    }
                }
        }
        
        cell.createdLabel.text = self.reviewCreatedArray[indexPath.row]
        
        if self.reviewScoreArray[indexPath.row] == nil {
            cell.scoreImageView.image = UIImage(named: "noScored")
        } else {
            cell.scoreImageView.image = UIImage(named: "score_\(self.reviewScoreArray[indexPath.row])")
        }
        cell.commentLabel.text = self.reviewCommentArray[indexPath.row]
        
        db.collection("niceReview").whereField("review_id", isEqualTo: self.reviewIdArray[indexPath.row]).getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return

            } else {
                for document in querySnapshot!.documents {
                    niceReviewArray.append(document.documentID)
                    niceReviewArray.count
                    
                    if niceReviewArray.count == 0 {
                        cell.likeCountLabel.text = ""
                    } else if niceReviewArray.count > 0 {
                        cell.likeCountLabel.text = "\(niceReviewArray.count)件のいいね！"
    
                    }
                }
            }
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.reviewIdArray.count

    }
    
    
}


