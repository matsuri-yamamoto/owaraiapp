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
import FirebaseStorage
import FirebaseStorageUI


class ComedianDetailViewController: UIViewController, YTPlayerViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    //comedian_idが渡される用の変数
    var comedianId: String = ""
        
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollVIewHight: NSLayoutConstraint!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewHight: NSLayoutConstraint!
    
    
    @IBOutlet weak var comedianNameLabel: UILabel!
    @IBOutlet weak var startYearLabel: UILabel!
//    @IBOutlet weak var comedianTypeLabel: UILabel!
    @IBOutlet weak var comedyTypeLabel1: UILabel!
    @IBOutlet weak var comedyTypeLabel2: UILabel!
    @IBOutlet weak var comedianImageView: UIImageView!
    @IBOutlet weak var referenceButton: UIButton!
    @IBOutlet weak var scoreImageView: UIImageView!
    @IBOutlet weak var averageScoreLabel: UILabel!
    
    
    @IBOutlet weak var mediaButton1: UIButton!
    @IBOutlet weak var mediaButton2: UIButton!
    @IBOutlet weak var mediaButton3: UIButton!
    @IBOutlet weak var mediaButton4: UIButton!
    @IBOutlet weak var mediaButton5: UIButton!
    
    
    @IBOutlet weak var memberTitleLabel: UILabel!
    @IBOutlet weak var memberLabel1: UILabel!
    @IBOutlet weak var memberLabel2: UILabel!
    @IBOutlet weak var memberLabel3: UILabel!
    
    
    
    //レビュー・あとでみるボタンの画像を設定するための接続
    @IBOutlet weak var reviewButton: UIButton!
    @IBOutlet weak var stockButton: UIButton!
    //レビュー・あとでみるボタンの件数ラベルを設定するための接続
    @IBOutlet weak var reviewCountLabel: UILabel!
    @IBOutlet weak var stockCountLabel: UILabel!
    
    @IBOutlet weak var reviewImageView: UIImageView!
    @IBOutlet weak var stockImageView: UIImageView!
    
    
    //Youtube動画のパラメータを格納する変数
    var movieId1: String?
    var movieId2: String?
    
    //著作権使用の許諾可否フラグを入れる変数
    var comedianCopyRight: String!
    
    //あとでみるボタンのデフォルトと保存時の画像
    let defaltStockButtonImage = UIImage(named: "defaltStockButton")
    let existStockButtonImage = UIImage(named: "existStockButton")
    //あとでみるに保存するための芸人の表示名を取得する変数
    var comedianDisplayName: String = ""
    
    
    
    //URLを持つ各種メディアを格納する配列
    var mediaImageArray: [String] = []
    
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
    var playerView1 = YTPlayerView()
    var playerView2 = YTPlayerView()
    
    
    //reviewのtableView
    let tableView = UITableView(frame: .zero, style: .plain)
    
    //reviewをセットする配列(別画面から戻る場合などにレビュー×2が読み込まれてしまうので、一旦この配列に入れてあとでユニークにする)
    var reviewBeforeUniqueArray: [String] = []

    //ブロックしている・されているユーザーの配列
    var blockingUserArray: [String] = []
    var blockedUserArray: [String] = []
    
    //reviewのtableViewにセットする配列
    var reviewIdArray: [String] = []
    var reviewUserNameArray: [String] = []
    var reviewDisplayIdArray: [String] = []
    var reviewUserIdArray: [String] = []
    var reviewCreatedArray: [String] = []
    var reviewScoreArray: [String] = []
    var reviewCommentArray: [String] = []
    
    //いいねボタン用の画像
    let likeImage = UIImage(systemName: "heart.fill")
    let unLikeImage = UIImage(systemName: "heart")
    //review件数のラベル(cellのクラスに渡す用)
    var likeCountLabelText :String = ""
    
    var referenceUrl :String = ""
    var referenceName :String = ""

    var reviewId :String = ""
    
    //Firestoreを使うための下準備
    let currentUser = Auth.auth().currentUser
    let db = Firestore.firestore()
    
    //画像のパス
    let storage = Storage.storage(url:"gs://owaraiapp-f80fd.appspot.com").reference()

    // インジゲーターの設定
    var indicator = UIActivityIndicatorView()

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // 表示位置を設定（画面中央）
        self.indicator.center = view.center
        // インジケーターのスタイルを指定（白色＆大きいサイズ）
        self.indicator.style = .large
        // インジケーターの色を設定（青色）
        self.indicator.color = UIColor.darkGray
        // インジケーターを View に追加
        view.addSubview(indicator)

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.indicator.startAnimating()
        
        self.reviewIdArray = []
        self.reviewUserNameArray = []
        self.reviewDisplayIdArray = []
        self.reviewUserIdArray = []
        self.reviewCreatedArray = []
        self.reviewScoreArray = []
        self.reviewCommentArray = []

        
//        self.scrollVIewHight.constant = CGFloat(2000)
        
        print("comedian:\(comedianId)")
        
        //レビューボタンのテキストをセット
        db.collection("review").whereField("comedian_id", isEqualTo: self.comedianId).whereField("user_id", isEqualTo: currentUser?.uid).getDocuments() {(querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                
                if querySnapshot?.documents.count == 0 {
                    
                    //レビュー前ユーザーのレビューボタンの状態
//                    self.reviewLabel.text = ""
//                    self.reviewLabel.font = UIFont.systemFont(ofSize: 14)
                    self.reviewButton.backgroundColor = UIColor.systemYellow
                    self.reviewImageView.tintColor = #colorLiteral(red: 0.424124063, green: 0.424124063, blue: 0.424124063, alpha: 1)
                    self.reviewCountLabel.tintColor = #colorLiteral(red: 0.424124063, green: 0.424124063, blue: 0.424124063, alpha: 1)
                    
                } else {
                    
                    //レビュー済みユーザーのレビューボタンの状態
//                    self.reviewLabel.text = "レビュー" + "\n" + "編集"
                    self.reviewButton.backgroundColor = #colorLiteral(red: 1, green: 0.9310497734, blue: 0.695790851, alpha: 1)
                    self.reviewImageView.tintColor = #colorLiteral(red: 0.6666666865, green: 0.6238060739, blue: 0.6320286928, alpha: 1)
                    self.reviewCountLabel.tintColor = #colorLiteral(red: 0.6666666865, green: 0.6238060739, blue: 0.6320286928, alpha: 1)

                }
            }
        }
        
        
        self.tableView.rowHeight = UITableView.automaticDimension;
        // set estimatedRowHeight to whatever is the fallBack rowHeight
        
        
        //レビューボタンの画像を設定
        
        //reviewドキュメントからscoreを参照
        //reviewのtableViewにセットする配列を作る(userName,displayId,create_datetime,score,comment)
        
        //reviewのtimestamp型、number型のデータを取得するためのデータ型変換用
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "ja_JP")
        
        
        
        db.collection("review").whereField("comedian_id", isEqualTo: comedianId).whereField("private_flag", isEqualTo: false).whereField("delete_flag", isEqualTo: false).order(by: "update_datetime", descending: true).getDocuments() {(querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                
                var scoreArray:[Float] = []
                
                //レビューボタンの件数ラベルを設定
                self.reviewCountLabel.text = "\(querySnapshot!.documents.count)"

                
                for document in querySnapshot!.documents {
                    

                    //平均スコアを算出し、画像を設定
                    scoreArray.append(document.data()["score"] as! Float)
                    var averageScore = scoreArray.reduce(0, +) / Float(scoreArray.count)
                    
                    self.averageScoreLabel.text = String(format: "%.1f", averageScore)
                    
                    if averageScore == nil {
                        self.scoreImageView.image = UIImage(named: "noScored")
                    } else {
                        self.scoreImageView.image = UIImage(named: "score_\(String(format: "%.1f", averageScore))")
                    }
                    
                    //自分がブロック中のユーザーを取得
                    self.db.collection("block_user").whereField("blocking_user_id", isEqualTo: self.currentUser?.uid).whereField("valid_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).limit(to: 10).getDocuments() { [self] (querySnapshot, err) in

                        if let err = err {
                            print("Error getting documents: \(err)")
                            return

                        } else {
                            for document in querySnapshot!.documents {
                                
                                self.blockingUserArray.append(document.data()["blocked_user_id"] as! String)
                                
                            }
                            
                            //自分をブロックしているユーザーを取得
                            self.db.collection("block_user").whereField("blocked_user_id", isEqualTo: self.currentUser?.uid).whereField("valid_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).limit(to: 10).getDocuments() { [self] (querySnapshot, err) in

                                if let err = err {
                                    print("Error getting documents: \(err)")
                                    return

                                } else {
                                    for document in querySnapshot!.documents {
                                        
                                        self.blockedUserArray.append(document.data()["blocking_user_id"] as! String)
                                        
                                    }
                                    
                                    //ブロックしているユーザーもブロックされているユーザーもいる場合
                                    if self.blockingUserArray != [] && self.blockedUserArray != [] {
                                        
                                        self.db.collection("review").whereField("comedian_id", isEqualTo: self.comedianId).whereField("private_flag", isEqualTo: false).whereField("delete_flag", isEqualTo: false).whereField("user_id", notIn: self.blockingUserArray).whereField("user_id", notIn: self.blockedUserArray).order(by: "user_id", descending: true).order(by: "update_datetime", descending: true).limit(to: 50).getDocuments() { [self] (querySnapshot, err) in

                                            if let err = err {
                                                print("Error getting documents: \(err)")
                                                return

                                            } else {
                                                for document in querySnapshot!.documents {
                                                    
                                                    //レビューを配列で取得(別画面から戻る場合などにレビュー×2が読み込まれてしまうので、一旦仮の配列に入れてあとでユニークにする)
                                                    self.reviewBeforeUniqueArray.append(document.documentID)
                                                    print("self.reviewBeforeUniqueArray:\(self.reviewBeforeUniqueArray)")
                                                    
                                                    
                                                    //以下、reviewのtableViewにセットする配列
                                                    //レビューをユニークにする
                                                    var reviewId = Set<String>()
                                                    self.reviewIdArray = self.reviewBeforeUniqueArray.filter { reviewId.insert($0).inserted }
                                                    
                                                    
                                                    self.reviewUserIdArray.append(document.data()["user_id"] as! String)
                                                    self.reviewUserNameArray.append(document.data()["user_name"] as! String)
                                                    self.reviewDisplayIdArray.append(document.data()["display_id"] as! String)
                                                    
                                                    //一旦FSのtimestampでデータを呼ぶ
                                                    let reviewCreatedDate = document.data()["create_datetime"] as! Timestamp
                                                    //Swiftのdateに変換
                                                    reviewCreatedDate.dateValue()
                                                    self.reviewCreatedArray.append(dateFormatter.string(from: reviewCreatedDate.dateValue()))
                                                    
                                                    self.reviewScoreArray.append(String(document.data()["score"] as! Float))
                                                    self.reviewCommentArray.append(document.data()["comment"] as! String)
                                                }
                                                self.tableView.reloadData()
                                            }
                                        }
                                    }
                                    
                                    //ブロックしているユーザーはいるがブロックはされていない場合
                                    if self.blockingUserArray != [] && self.blockedUserArray == [] {
                                        
                                        self.db.collection("review").whereField("comedian_id", isEqualTo: self.comedianId).whereField("private_flag", isEqualTo: false).whereField("delete_flag", isEqualTo: false).whereField("user_id", notIn: self.blockingUserArray).order(by: "user_id", descending: true).order(by: "update_datetime", descending: true).limit(to: 50).getDocuments() { [self] (querySnapshot, err) in

                                            if let err = err {
                                                print("Error getting documents: \(err)")
                                                return

                                            } else {
                                                for document in querySnapshot!.documents {
                                                    
                                                    //レビューを配列で取得(別画面から戻る場合などにレビュー×2が読み込まれてしまうので、一旦仮の配列に入れてあとでユニークにする)
                                                    self.reviewBeforeUniqueArray.append(document.documentID)
                                                    print("self.reviewBeforeUniqueArray:\(self.reviewBeforeUniqueArray)")
                                                    
                                                    
                                                    //以下、reviewのtableViewにセットする配列
                                                    //レビューをユニークにする
                                                    var reviewId = Set<String>()
                                                    self.reviewIdArray = self.reviewBeforeUniqueArray.filter { reviewId.insert($0).inserted }
                                                    
                                                    
                                                    self.reviewUserIdArray.append(document.data()["user_id"] as! String)
                                                    self.reviewUserNameArray.append(document.data()["user_name"] as! String)
                                                    self.reviewDisplayIdArray.append(document.data()["display_id"] as! String)
                                                    
                                                    //一旦FSのtimestampでデータを呼ぶ
                                                    let reviewCreatedDate = document.data()["create_datetime"] as! Timestamp
                                                    //Swiftのdateに変換
                                                    reviewCreatedDate.dateValue()
                                                    self.reviewCreatedArray.append(dateFormatter.string(from: reviewCreatedDate.dateValue()))
                                                    
                                                    self.reviewScoreArray.append(String(document.data()["score"] as! Float))
                                                    self.reviewCommentArray.append(document.data()["comment"] as! String)
                                                }
                                                self.tableView.reloadData()
                                            }
                                        }
                                    }
                                    
                                    //ブロックはしていないがブロックされている場合
                                    if self.blockingUserArray == [] && self.blockedUserArray != [] {
                                        
                                        self.db.collection("review").whereField("comedian_id", isEqualTo: self.comedianId).whereField("private_flag", isEqualTo: false).whereField("delete_flag", isEqualTo: false).whereField("user_id", notIn: self.blockedUserArray).order(by: "user_id", descending: true).order(by: "update_datetime", descending: true).limit(to: 50).getDocuments() { [self] (querySnapshot, err) in

                                            if let err = err {
                                                print("Error getting documents: \(err)")
                                                return

                                            } else {
                                                for document in querySnapshot!.documents {
                                                    
                                                    //レビューを配列で取得(別画面から戻る場合などにレビュー×2が読み込まれてしまうので、一旦仮の配列に入れてあとでユニークにする)
                                                    self.reviewBeforeUniqueArray.append(document.documentID)
                                                    print("self.reviewBeforeUniqueArray:\(self.reviewBeforeUniqueArray)")
                                                    
                                                    
                                                    //以下、reviewのtableViewにセットする配列
                                                    //レビューをユニークにする
                                                    var reviewId = Set<String>()
                                                    self.reviewIdArray = self.reviewBeforeUniqueArray.filter { reviewId.insert($0).inserted }
                                                    
                                                    
                                                    self.reviewUserIdArray.append(document.data()["user_id"] as! String)
                                                    self.reviewUserNameArray.append(document.data()["user_name"] as! String)
                                                    self.reviewDisplayIdArray.append(document.data()["display_id"] as! String)
                                                    
                                                    //一旦FSのtimestampでデータを呼ぶ
                                                    let reviewCreatedDate = document.data()["create_datetime"] as! Timestamp
                                                    //Swiftのdateに変換
                                                    reviewCreatedDate.dateValue()
                                                    self.reviewCreatedArray.append(dateFormatter.string(from: reviewCreatedDate.dateValue()))
                                                    
                                                    self.reviewScoreArray.append(String(document.data()["score"] as! Float))
                                                    self.reviewCommentArray.append(document.data()["comment"] as! String)
                                                }
                                                self.tableView.reloadData()
                                            }
                                        }
                                    }
                                    
                                    //ブロックをしてもされてもいない場合
                                    if self.blockingUserArray == [] && self.blockedUserArray == [] {
                                        
                                        self.db.collection("review").whereField("comedian_id", isEqualTo: self.comedianId).whereField("private_flag", isEqualTo: false).whereField("delete_flag", isEqualTo: false).order(by: "update_datetime", descending: true).limit(to: 50).getDocuments() { [self] (querySnapshot, err) in

                                            if let err = err {
                                                print("Error getting documents: \(err)")
                                                return

                                            } else {
                                                for document in querySnapshot!.documents {
                                                    
                                                    //レビューを配列で取得(別画面から戻る場合などにレビュー×2が読み込まれてしまうので、一旦仮の配列に入れてあとでユニークにする)
                                                    self.reviewBeforeUniqueArray.append(document.documentID)
                                                    print("self.reviewBeforeUniqueArray:\(self.reviewBeforeUniqueArray)")
                                                    
                                                    
                                                    //以下、reviewのtableViewにセットする配列
                                                    //レビューをユニークにする
                                                    var reviewId = Set<String>()
                                                    self.reviewIdArray = self.reviewBeforeUniqueArray.filter { reviewId.insert($0).inserted }
                                                    
                                                    
                                                    self.reviewUserIdArray.append(document.data()["user_id"] as! String)
                                                    self.reviewUserNameArray.append(document.data()["user_name"] as! String)
                                                    self.reviewDisplayIdArray.append(document.data()["display_id"] as! String)
                                                    
                                                    //一旦FSのtimestampでデータを呼ぶ
                                                    let reviewCreatedDate = document.data()["create_datetime"] as! Timestamp
                                                    //Swiftのdateに変換
                                                    reviewCreatedDate.dateValue()
                                                    self.reviewCreatedArray.append(dateFormatter.string(from: reviewCreatedDate.dateValue()))
                                                    
                                                    self.reviewScoreArray.append(String(document.data()["score"] as! Float))
                                                    self.reviewCommentArray.append(document.data()["comment"] as! String)
                                                }
                                                self.tableView.reloadData()
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
        
        //ストックボタンのテキストをセット
        db.collection("stock").whereField("comedian_id", isEqualTo: self.comedianId).whereField("user_id", isEqualTo: currentUser?.uid).whereField("valid_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                
                if querySnapshot?.documents.count == 0 {
                    
                    //あとでみる前ユーザーのあとでみるボタンの状態
//                    self.stockLabel.text = "あとでみる"
//                    self.stockLabel.font = UIFont.systemFont(ofSize: 14)
                    self.stockButton.backgroundColor = UIColor.systemYellow
                    self.stockImageView.tintColor = #colorLiteral(red: 0.424124063, green: 0.424124063, blue: 0.424124063, alpha: 1)
                    self.stockCountLabel.tintColor = #colorLiteral(red: 0.424124063, green: 0.424124063, blue: 0.424124063, alpha: 1)

                    
                } else {
                    
                    //あとでみる済みユーザーのあとでみるボタンの状態
//                    self.stockLabel.text = "あとでみる" + "\n" + "削除"
//                    self.stockLabel.font = UIFont.systemFont(ofSize: 12)
                    self.stockButton.backgroundColor = #colorLiteral(red: 1, green: 0.9310497734, blue: 0.695790851, alpha: 1)
                    self.stockImageView.tintColor = #colorLiteral(red: 0.6666666865, green: 0.6238060739, blue: 0.6320286928, alpha: 1)
                    self.stockCountLabel.tintColor = #colorLiteral(red: 0.6666666865, green: 0.6238060739, blue: 0.6320286928, alpha: 1)



                    
                }
            }
        }

        
        

        
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
        db.collection("stock").whereField("comedian_id", isEqualTo: comedianId).whereField("valid_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                
                self.stockCountLabel.text = "\(querySnapshot!.documents.count)"
                
            }
        }
        
        
        //comedianドキュメントから各項目を参照
        db.collection("comedian").whereField(FieldPath.documentID(), isEqualTo: comedianId).getDocuments() {(querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let comedian_name = document.data()["comedian_name"] as! String
                    let office_name = "（\(document.data()["office_name"] as! String)）"
                    self.comedianNameLabel.text = comedian_name + office_name
                    self.comedianDisplayName = document.data()["for_list_name"] as! String
                    
                    if document.data()["start_year"] as! String != "" {
                        self.startYearLabel.text = document.data()["start_year"] as! String + "結成"
                    }
//                    self.comedianTypeLabel.text = document.data()["comedian_type"] as? String
                    self.comedyTypeLabel1.text = document.data()["comedy_type_1"] as? String
                    self.comedyTypeLabel2.text = document.data()["comedy_type_2"] as? String
                    self.memberLabel1.text = document.data()["member_1"] as? String
                    
                    self.contentView.addSubview(self.comedianImageView)
                    
                    
                    self.movieId1 = document.data()["movie_1"] as? String
                    self.movieId2 = document.data()["movie_2"] as? String
                    
                    print("movieId2:\(self.movieId2!)")
                    
                    
                    if document.data()["member_1"] as? String == "　" {
                        self.memberTitleLabel.isHidden = true
                        self.memberLabel1.isHidden = true
                        self.memberLabel2.isHidden = true
                        self.memberLabel3.isHidden = true
                        
                    } else if document.data()["member_2"] as? String == "　" {
                        self.memberTitleLabel.text = "メンバー"
                        self.memberLabel2.isHidden = true
                        self.memberLabel3.isHidden = true
                        
                        self.memberLabel1.text = document.data()["member_1"] as? String
                        
                    } else if document.data()["member_3"] as? String == "　" {
                        self.memberTitleLabel.text = "メンバー"
                        self.memberLabel3.isHidden = true
                        
                        self.memberLabel1.text = document.data()["member_1"] as? String
                        self.memberLabel2.text = document.data()["member_2"] as? String
                        
                        
                    } else if document.data()["member_4"] as? String == "　"  {
                        self.memberTitleLabel.text = "メンバー"
                        self.memberLabel1.text = document.data()["member_1"] as? String
                        self.memberLabel2.text = document.data()["member_2"] as? String
                        self.memberLabel3.text = document.data()["member_3"] as? String
                        
                    } else {
                        self.memberTitleLabel.text = "メンバー(一部)"
                        self.memberLabel1.text = document.data()["member_1"] as? String
                        self.memberLabel2.text = document.data()["member_2"] as? String
                        self.memberLabel3.text = document.data()["member_3"] as? String
                        
                    }
                    
                    
                    
                    
                    self.comedianCopyRight = document.data()["copyright_flag"] as? String
                    
                    print("comedianCopyRight:\(self.comedianCopyRight)")
                    
                    
                    var reviewCount :Int?
                    
                    self.db.collection("review").whereField("comedian_id", isEqualTo: self.comedianId).whereField("private_flag", isEqualTo: false).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
                        
                        //メモ：呼ばれている
                        if let err = err {
                            print("Error getting documents: \(err)")
                            return
                            
                        } else {
                            
                            reviewCount = querySnapshot?.documents.count
                            
                            
                            //許諾取得済みなら宣材写真をセット
                            if self.comedianCopyRight == "true" {
                                
                                self.comedianImageView.image = UIImage(named: "\(self.comedianId)")
                                self.comedianImageView.contentMode = .scaleAspectFill
                                self.comedianImageView.clipsToBounds = true

                                                                                                

                                
//                                self.comedianImageView.image = UIImage(named: "\(self.comedianId)")
                                
                                
                                if self.movieId2 != "" {
                                    
                                    //レビューの件数に応じたcontentViewのheightになるように設定(レビュー1件あたりheight=300)
                                    print("self.reviewIdArray.count:\(reviewCount!)")
                                    
                                    self.contentViewHight.constant = CGFloat(250*reviewCount! + 870)
                                    
                                    print("contentViewHight.constant:\(self.contentViewHight.constant)")
                                    
                                    //contentViewの高さをscrollViewに反映させる
                                    self.scrollVIewHight.constant = CGFloat(self.contentViewHight.constant)

                                    
                                    //参考：https://dev.classmethod.jp/articles/youtube-player-ios-helper/
                                    //動画の見出しをセットする
                                    let movieLabel = UILabel(frame: CGRect(x: 0, y: 330, width: self.contentView.frame.width, height: 25))
                                    movieLabel.text = "　ネタ動画"
                                    movieLabel.font = UIFont.systemFont(ofSize: 12)
                                    movieLabel.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
                                    movieLabel.backgroundColor = #colorLiteral(red: 0.8564946339, green: 0.8564946339, blue: 0.8564946339, alpha: 1)
                                    
                                    self.contentView.addSubview(movieLabel)
                                    
                                    
                                    
                                    //1つ目の動画をセットする
                                    let youtubeView1 = YTPlayerView(frame: CGRect(x: self.contentView.frame.width/2 - (self.contentView.frame.width*0.9)/2, y: 370, width: self.contentView.frame.width*0.9, height: 200))
                                    
                                    youtubeView1.load(withVideoId: "\(self.movieId1!)", playerVars: ["playsinline":1])
                                    youtubeView1.delegate = self;
                                    self.contentView.addSubview(youtubeView1)
                                    
                                    
                                    //2つ目の動画を作成し埋め込む
                                    
                                    let youtubeView2 = YTPlayerView(frame: CGRect(x: self.contentView.frame.width/2 - (self.contentView.frame.width*0.9)/2, y: 590, width: self.contentView.frame.width*0.9, height: 200))
                                    
                                    youtubeView2.load(withVideoId: "\(self.movieId2!)", playerVars: ["playsinline":1])
                                    youtubeView2.delegate = self;
                                    self.contentView.addSubview(youtubeView2)
                                    
                                                                        
                                    //レビューの見出しをセットする
                                    let reviewLabel = UILabel(frame: CGRect(x: 0, y: 815, width: self.contentView.frame.width, height: 25))
                                    reviewLabel.text = "　みんなの感想"
                                    reviewLabel.font = UIFont.systemFont(ofSize: 12)
                                    reviewLabel.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
                                    reviewLabel.backgroundColor = #colorLiteral(red: 0.8564946339, green: 0.8564946339, blue: 0.8564946339, alpha: 1)
                                    
                                    self.contentView.addSubview(reviewLabel)
                                    
                                    
                                    //2つ分の動画の下にレビューをセットする
                                    self.contentView.addSubview(self.tableView)
                                    self.tableView.backgroundColor = #colorLiteral(red: 0.9694761634, green: 0.9694761634, blue: 0.9694761634, alpha: 1)
                                    
                                    self.tableView.translatesAutoresizingMaskIntoConstraints = false
                                    self.tableView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 840.0).isActive = true
                                    self.tableView.heightAnchor.constraint(equalTo: self.contentView.heightAnchor).isActive = true
                                    self.tableView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor).isActive = true
                                    self.tableView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor).isActive = true
                                    self.tableView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
                                    
                                    self.tableView.delegate = self
                                    self.tableView.dataSource = self
                                    
                                    // カスタムセルを登録する
                                    let nib = UINib(nibName: "ComedianReviewTableViewCell", bundle: nil)
                                    self.tableView.register(nib, forCellReuseIdentifier: "cell")
                                    
                                    
                                } else if self.movieId1 != "" {
                                    
                                    //レビューの件数に応じたcontentViewのheightになるように設定(レビュー1件あたりheight=300)
                                    print("self.reviewIdArray.count:\(reviewCount!)")
                                    
                                    self.contentViewHight.constant = CGFloat(250*reviewCount! + 670)
                                    
                                    print("contentViewHight.constant:\(self.contentViewHight.constant)")
                                    
                                    //contentViewの高さをscrollViewに反映させる
                                    self.scrollVIewHight.constant = CGFloat(self.contentViewHight.constant)

                                    
                                    //動画の見出しをセットする
                                    let movieLabel = UILabel(frame: CGRect(x: 0, y: 330, width: self.contentView.frame.width, height: 25))
                                    movieLabel.text = "　ネタ動画"
                                    movieLabel.font = UIFont.systemFont(ofSize: 12)
                                    movieLabel.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
                                    movieLabel.backgroundColor = #colorLiteral(red: 0.8564946339, green: 0.8564946339, blue: 0.8564946339, alpha: 1)
                                    
                                    self.contentView.addSubview(movieLabel)
                                    
                                    
                                    //1つ目の動画をセットする
                                    let youtubeView1 = YTPlayerView(frame: CGRect(x: self.contentView.frame.width/2 - (self.contentView.frame.width*0.9)/2, y: 370, width: self.contentView.frame.width*0.9, height: 200))
                                    
                                    youtubeView1.load(withVideoId: "\(self.movieId1!)", playerVars: ["playsinline":1])
                                    youtubeView1.delegate = self;
                                    self.contentView.addSubview(youtubeView1)
                                    
                                    
                                    //レビューの見出しをセットする
                                    let reviewLabel = UILabel(frame: CGRect(x: 0, y: 600, width: self.contentView.frame.width, height: 25))
                                    reviewLabel.text = "　みんなの感想"
                                    reviewLabel.font = UIFont.systemFont(ofSize: 12)
                                    reviewLabel.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
                                    reviewLabel.backgroundColor = #colorLiteral(red: 0.8564946339, green: 0.8564946339, blue: 0.8564946339, alpha: 1)
                                    
                                    self.contentView.addSubview(reviewLabel)
                                    
                                    
                                    //1つ分の動画の下にレビューをセットする
                                    self.contentView.addSubview(self.tableView)
                                    self.tableView.backgroundColor = #colorLiteral(red: 0.9694761634, green: 0.9694761634, blue: 0.9694761634, alpha: 1)
                                    
                                    self.tableView.translatesAutoresizingMaskIntoConstraints = false
                                    self.tableView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 625.0).isActive = true
                                    self.tableView.heightAnchor.constraint(equalTo: self.contentView.heightAnchor).isActive = true
                                    self.tableView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor).isActive = true
                                    self.tableView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor).isActive = true
                                    self.tableView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
                                    
                                    self.tableView.delegate = self
                                    self.tableView.dataSource = self
                                    
                                    // カスタムセルを登録する
                                    let nib = UINib(nibName: "ComedianReviewTableViewCell", bundle: nil)
                                    self.tableView.register(nib, forCellReuseIdentifier: "cell")
                                    
                                    
                                } else {
                                    
                                    //レビューの件数に応じたcontentViewのheightになるように設定(レビュー1件あたりheight=300)
                                    print("self.reviewIdArray.count:\(reviewCount!)")
                                    
                                    self.contentViewHight.constant = CGFloat(250*reviewCount! + 395)
                                    
                                    print("contentViewHight.constant:\(self.contentViewHight.constant)")
                                    
                                    //contentViewの高さをscrollViewに反映させる
                                    self.scrollVIewHight.constant = CGFloat(self.contentViewHight.constant)

                                    
                                    //レビューの見出しをセットする
                                    let reviewLabel = UILabel(frame: CGRect(x: 0, y: 370, width: self.contentView.frame.width, height: 25))
                                    reviewLabel.text = "　みんなの感想"
                                    reviewLabel.font = UIFont.systemFont(ofSize: 12)
                                    reviewLabel.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
                                    reviewLabel.backgroundColor = #colorLiteral(red: 0.8564946339, green: 0.8564946339, blue: 0.8564946339, alpha: 1)
                                    
                                    self.contentView.addSubview(reviewLabel)
                                    
                                    
                                    //動画なしでレビューをセットする
                                    self.contentView.addSubview(self.tableView)
                                    self.tableView.backgroundColor = #colorLiteral(red: 0.9694761634, green: 0.9694761634, blue: 0.9694761634, alpha: 1)

                                    
                                    self.tableView.translatesAutoresizingMaskIntoConstraints = false
                                    self.tableView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 395.0).isActive = true
                                    self.tableView.heightAnchor.constraint(equalTo: self.contentView.heightAnchor).isActive = true
                                    self.tableView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor).isActive = true
                                    self.tableView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor).isActive = true
                                    self.tableView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
                                    
                                    self.tableView.delegate = self
                                    self.tableView.dataSource = self
                                    
                                    // カスタムセルを登録する
                                    let nib = UINib(nibName: "ComedianReviewTableViewCell", bundle: nil)
                                    self.tableView.register(nib, forCellReuseIdentifier: "cell")
                                    

                                }
                                
                                self.referenceButton.setTitle("", for: .normal)

                                
                            }
                            if self.comedianCopyRight == "false" {
                                
                                self.comedianImageView.image = UIImage(named: "noImage")
                                
                                //レビューの件数に応じたcontentViewのheightになるように設定(レビュー1件あたりheight=300)
                                print("self.reviewIdArray.count:\(reviewCount!)")
                                
                                self.contentViewHight.constant = CGFloat(250*reviewCount! + 395)
                                
                                print("contentViewHight.constant:\(self.contentViewHight.constant)")
                                
                                //contentViewの高さをscrollViewに反映させる
                                self.scrollVIewHight.constant = CGFloat(self.contentViewHight.constant)
                                
                                
                                //レビューの見出しをセットする
                                let reviewLabel = UILabel(frame: CGRect(x: 0, y: 370, width: self.contentView.frame.width, height: 25))
                                reviewLabel.text = "　みんなの感想"
                                reviewLabel.font = UIFont.systemFont(ofSize: 12)
                                reviewLabel.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
                                reviewLabel.backgroundColor = #colorLiteral(red: 0.8564946339, green: 0.8564946339, blue: 0.8564946339, alpha: 1)
                                
                                self.contentView.addSubview(reviewLabel)
                                
                                
                                //動画なしでレビューをセットする
                                self.contentView.addSubview(self.tableView)
                                self.tableView.backgroundColor = #colorLiteral(red: 0.9694761634, green: 0.9694761634, blue: 0.9694761634, alpha: 1)
                                
                                self.tableView.translatesAutoresizingMaskIntoConstraints = false
                                self.tableView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 395.0).isActive = true
                                self.tableView.heightAnchor.constraint(equalTo: self.contentView.heightAnchor).isActive = true
                                self.tableView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor).isActive = true
                                self.tableView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor).isActive = true
                                self.tableView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
                                
                                self.tableView.delegate = self
                                self.tableView.dataSource = self
                                
                                // カスタムセルを登録する
                                let nib = UINib(nibName: "ComedianReviewTableViewCell", bundle: nil)
                                self.tableView.register(nib, forCellReuseIdentifier: "cell")
                                
                                self.referenceButton.setTitle("", for: .normal)

                                
                            }
                            
                            if self.comedianCopyRight == "reference" {
                                

                                let comedianImage: UIImage? = UIImage(named: "\(self.comedianId)")
                                
                                //画像がAssetsにあれば画像と引用元を表示し、なければ引用元なしのnoImageをセット
                                if let validImage = comedianImage {
                                    
                                    self.db.collection("comedian").whereField(FieldPath.documentID(), isEqualTo: self.comedianId).getDocuments() {(querySnapshot, err) in
                                        
                                        if let err = err {
                                            print("Error getting documents: \(err)")
                                            return
                                            
                                        } else {
                                            for document in querySnapshot!.documents {
                                                
                                                self.referenceName = document.data()["reference_name"] as! String
                                                self.referenceUrl = document.data()["reference_url"] as! String

                                            }
                                            
                                            print("referenceName:\(self.referenceName)")
                                            
                                            self.referenceButton.contentHorizontalAlignment = .left
                                            self.referenceButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 6.0)
                                            self.referenceButton.setTitle(self.referenceName, for: .normal)
                                            self.referenceButton.addTarget(self, action: #selector(self.tappedReferenceButton(sender:)), for: .touchUpInside)
                                            
                                        }
                                    }
                                    
                                    self.comedianImageView.image = comedianImage
                                    self.comedianImageView.contentMode = .scaleAspectFill
                                    self.comedianImageView.clipsToBounds = true

                                    
                                } else {
                                    
                                    //画像がない場合
                                    
                                    self.comedianImageView.image = UIImage(named: "noImage")
                                    
                                }
                                

                                //レビューの件数に応じたcontentViewのheightになるように設定(レビュー1件あたりheight=300)
                                print("self.reviewIdArray.count:\(reviewCount!)")
                                
                                self.contentViewHight.constant = CGFloat(250*reviewCount! + 395)
                                
                                print("contentViewHight.constant:\(self.contentViewHight.constant)")
                                
                                //contentViewの高さをscrollViewに反映させる
                                self.scrollVIewHight.constant = CGFloat(self.contentViewHight.constant)
                                
                                
                                //レビューの見出しをセットする
                                let reviewLabel = UILabel(frame: CGRect(x: 0, y: 370, width: self.contentView.frame.width, height: 25))
                                reviewLabel.text = "　みんなの感想"
                                reviewLabel.font = UIFont.systemFont(ofSize: 12)
                                reviewLabel.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
                                reviewLabel.backgroundColor = #colorLiteral(red: 0.8564946339, green: 0.8564946339, blue: 0.8564946339, alpha: 1)
                                
                                self.contentView.addSubview(reviewLabel)
                                
                                
                                //動画なしでレビューをセットする
                                self.contentView.addSubview(self.tableView)
                                self.tableView.backgroundColor = #colorLiteral(red: 0.9694761634, green: 0.9694761634, blue: 0.9694761634, alpha: 1)
                                
                                self.tableView.translatesAutoresizingMaskIntoConstraints = false
                                self.tableView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 395.0).isActive = true
                                self.tableView.heightAnchor.constraint(equalTo: self.contentView.heightAnchor).isActive = true
                                self.tableView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor).isActive = true
                                self.tableView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor).isActive = true
                                self.tableView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
                                
                                self.tableView.delegate = self
                                self.tableView.dataSource = self
                                
                                // カスタムセルを登録する
                                let nib = UINib(nibName: "ComedianReviewTableViewCell", bundle: nil)
                                self.tableView.register(nib, forCellReuseIdentifier: "cell")
                                
                                
                            }
                            
                            if reviewCount! == 0 {
                                
                                let noReviewLabel = UILabel()
                                noReviewLabel.frame = CGRect(x: 5, y: 2, width: 200, height: 50)
                                
                                noReviewLabel.text = "まだレビューはありません"
                                noReviewLabel.font = UIFont.systemFont(ofSize: 12)
                                noReviewLabel.textColor = #colorLiteral(red: 0.7311395201, green: 0.7311395201, blue: 0.7311395201, alpha: 1)
                                noReviewLabel.backgroundColor = #colorLiteral(red: 0.9694761634, green: 0.9694761634, blue: 0.9694761634, alpha: 1)
                                
                                self.tableView.addSubview(noReviewLabel)
                                
                            }
                            
                        }
                        
                    }
                    //mediaArrayを作る
                    //append関数はnilを許容できない
                    //Stringでメディアの種類(UIImageのname)を入れて198行目からの画像をセットするところでUIImageを設定
                    
                    if document.data()["twitter_1"] as! String != "" {
                        self.mediaImageArray.append("twitter")
                    }
                    if document.data()["twitter_2"] as! String != "" {
                        self.mediaImageArray.append("twitter")
                    }
                    if document.data()["twitter_3"] as! String != "" {
                        self.mediaImageArray.append("twitter")
                    }
                    if document.data()["youtube_1"] as! String != "" {
                        self.mediaImageArray.append("youtube")
                    }
                    if document.data()["youtube_2"] as! String != "" {
                        self.mediaImageArray.append("youtube")
                    }
                    
                    
                    print("mediaImageArray:\(self.mediaImageArray)")
                    
                    
                    //mediaUrlArrayを作る
                    if document.data()["twitter_1"] as! String != "" {
                        self.mediaUrlArray.append(document.data()["twitter_1"] as! String)
                    }
                    if document.data()["twitter_2"] as! String != "" {
                        self.mediaUrlArray.append(document.data()["twitter_2"] as! String)
                    }
                    if document.data()["twitter_3"] as! String != "" {
                        self.mediaUrlArray.append(document.data()["twitter_3"] as! String)
                    }
                    if document.data()["youtube_1"] as! String != "" {
                        self.mediaUrlArray.append(document.data()["youtube_1"] as! String)
                    }
                    if document.data()["youtube_2"] as! String != "" {
                        self.mediaUrlArray.append(document.data()["youtube_2"] as! String)
                    }
                    
                    print("mediaUrlArray:\(self.mediaUrlArray)")
                    
                    //配列のn番目のインデックスが存在していたら、画像をセットしボタンを有効化する
                    //そうでなければボタンを非表示
                    if self.mediaImageArray.indices.contains(0) == true {
                        
                        //ボタンの角を丸くする
                        self.mediaButton1.layer.cornerRadius = 8
                        self.mediaButton1.clipsToBounds = true
                        
                        //mediaInamgeArrayの該当indexの画像をセット
                        self.mediaButton1.setImage(UIImage(named: "\(self.mediaImageArray[0])"), for: .normal)
                        //タップでmediaUrlArrayの該当indexのurlに遷移するメソッド
                        self.mediaButton1.addTarget(self, action: #selector(self.mb1Tapped(_ :)), for: .touchUpInside)
                        
                        //画像のサイズをボタンのサイズに合わせる
                        self.mediaButton1.imageView?.contentMode = .scaleAspectFill
                        self.mediaButton1.contentHorizontalAlignment = .fill
                        self.mediaButton1.contentVerticalAlignment = .fill
                        
                        
                    } else {
                        self.mediaButton1.isHidden = true
                    }
                    
                    if self.mediaImageArray.indices.contains(1) == true {
                        
                        //ボタンの角を丸くする
                        self.mediaButton2.layer.cornerRadius = 8
                        self.mediaButton2.clipsToBounds = true
                        
                        
                        //mediaInamgeArrayの該当indexの画像をセット
                        self.mediaButton2.setImage(UIImage(named: "\(self.mediaImageArray[1])"), for: .normal)
                        //タップでmediaUrlArrayの該当indexのurlに遷移するメソッド
                        self.mediaButton2.addTarget(self, action: #selector(self.mb2Tapped(_ :)), for: .touchUpInside)
                        
                        //画像のサイズをボタンのサイズに合わせる
                        self.mediaButton2.imageView?.contentMode = .scaleAspectFill
                        self.mediaButton2.contentHorizontalAlignment = .fill
                        self.mediaButton2.contentVerticalAlignment = .fill
                        
                        
                    } else {
                        self.mediaButton2.isHidden = true
                    }
                    
                    if self.mediaImageArray.indices.contains(2) == true {
                        
                        //ボタンの角を丸くする
                        self.mediaButton3.layer.cornerRadius = 8
                        self.mediaButton3.clipsToBounds = true
                        
                        
                        //mediaInamgeArrayの該当indexの画像をセット
                        self.mediaButton3.setImage(UIImage(named: "\(self.mediaImageArray[2])"), for: .normal)
                        //タップでmediaUrlArrayの該当indexのurlに遷移するメソッド
                        self.mediaButton3.addTarget(self, action: #selector(self.mb3Tapped(_ :)), for: .touchUpInside)
                        
                        //画像のサイズをボタンのサイズに合わせる
                        self.mediaButton3.imageView?.contentMode = .scaleAspectFill
                        self.mediaButton3.contentHorizontalAlignment = .fill
                        self.mediaButton3.contentVerticalAlignment = .fill
                        
                        
                    } else {
                        self.mediaButton3.isHidden = true
                    }
                    
                    if self.mediaImageArray.indices.contains(3) == true {
                        
                        //ボタンの角を丸くする
                        self.mediaButton4.layer.cornerRadius = 8
                        self.mediaButton4.clipsToBounds = true
                        
                        //mediaInamgeArrayの該当indexの画像をセット
                        self.mediaButton4.setImage(UIImage(named: "\(self.mediaImageArray[3])"), for: .normal)
                        //タップでmediaUrlArrayの該当indexのurlに遷移するメソッド
                        self.mediaButton4.addTarget(self, action: #selector(self.mb4Tapped(_ :)), for: .touchUpInside)
                        
                        //画像のサイズをボタンのサイズに合わせる
                        self.mediaButton4.imageView?.contentMode = .scaleAspectFill
                        self.mediaButton4.contentHorizontalAlignment = .fill
                        self.mediaButton4.contentVerticalAlignment = .fill
                        
                        
                    } else {
                        self.mediaButton4.isHidden = true
                    }
                    
                    if self.mediaImageArray.indices.contains(4) == true {
                        
                        //ボタンの角を丸くする
                        self.mediaButton5.layer.cornerRadius = 8
                        self.mediaButton5.clipsToBounds = true
                        
                        //mediaInamgeArrayの該当indexの画像をセット
                        self.mediaButton5.setImage(UIImage(named: "\(self.mediaImageArray[4])"), for: .normal)
                        //タップでmediaUrlArrayの該当indexのurlに遷移するメソッド
                        self.mediaButton5.addTarget(self, action: #selector(self.mb5Tapped(_ :)), for: .touchUpInside)
                        
                        //画像のサイズをボタンのサイズに合わせる
                        self.mediaButton5.imageView?.contentMode = .scaleAspectFill
                        self.mediaButton5.contentHorizontalAlignment = .fill
                        self.mediaButton5.contentVerticalAlignment = .fill
                        
                        
                    } else {
                        self.mediaButton5.isHidden = true
                    }
                }
                
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
                    
                    
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .short
                    dateFormatter.timeStyle = .short
                    dateFormatter.locale = Locale(identifier: "ja_JP")
                    dateFormatter.dateFormat = "yyyy/MM/dd"
                    let date = Date()
                    let pvDate = dateFormatter.string(from: date)
                    
                    
                    self.db.collection("pv_comedian").whereField("comedian_id", isEqualTo: self.comedianId).whereField("user_id", isEqualTo: Auth.auth().currentUser?.uid).whereField("pv_date", isEqualTo: pvDate).getDocuments() { [self](querySnapshot, err) in
                        
                        if let err = err {
                            print("Error getting documents: \(err)")
                            return
                            
                        } else {
                            
                            if (querySnapshot?.documents.count)! > 0 {
                                
                                return
                                
                            }
                            
                            if (querySnapshot?.documents.count) == 0 {
                                
                                //レコード保存
                                let pvRec = Firestore.firestore().collection("pv_comedian").document()
                                let pvDic = [
                                    "user_id": Auth.auth().currentUser?.uid,
                                    "comedian_id": self.comedianId,
                                    "comedian_display_name": self.comedianDisplayName,
                                    "pv_date": pvDate,
                                    "create_datetime": FieldValue.serverTimestamp(),
                                    "update_datetime": FieldValue.serverTimestamp(),
                                    "delete_flag": false,
                                    "delete_datetime": nil,
                                ] as [String : Any?]
                                pvRec.setData(pvDic as [String : Any]) { err in
                                    if let err = err {
                                        print("Error updating document: \(err)")
                                    } else {
                                        print("Document successfully updated")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        
        self.indicator.stopAnimating()

        //pvログ
        AnalyticsUtil.sendScreenName(ScreenEvent(screenName: .comedianDetailVC))
        
        
    }
    
    

    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//
//        self.tableView.estimatedRowHeight = 300
//        return UITableView.automaticDimension
//
//    }
    
    
    @objc func tappedReferenceButton(sender: UIButton) {

        let referenceUrl = URL(string: "\(self.referenceUrl)")
        UIApplication.shared.open(referenceUrl!)
        
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
    
        
        if currentUser?.uid == nil {
            //ログインしていない場合、ログイン推奨ページに遷移
            let recLoginVC = storyboard?.instantiateViewController(withIdentifier: "RecLogin") as! RecommendLoginViewController
            
            self.navigationController?.pushViewController(recLoginVC, animated: true)
            
            
            //ログ
            AnalyticsUtil.sendAction(ActionEvent(screenName: .comedianDetailVC,
                                                         actionType: .tap,
                                                 actionLabel: .template(ActionLabelTemplate.comedianReviewRecLoginPush)))

            
        } else {
            
            //レビュー画面に遷移
            let reviewVC = storyboard?.instantiateViewController(withIdentifier: "Review") as! ReviewViewController
            let nav = UINavigationController(rootViewController: reviewVC)
            
            //comedian_idを渡す
            reviewVC.comedianID = self.comedianId
            
//            //comedianNameLabelをStringに変換して芸人名を渡す
//            var comedianName = comedianNameLabel.text! as String
            reviewVC.comedianName = self.comedianDisplayName
            
            self.present(nav, animated: true, completion: nil)
            
            //ログ
            AnalyticsUtil.sendAction(ActionEvent(screenName: .comedianDetailVC,
                                                         actionType: .tap,
                                                 actionLabel: .template(ActionLabelTemplate.reviewButtonTap)))

        }
        
    }
    
    @IBAction func stockButton(_ sender: Any) {
        
        
        if currentUser?.uid == nil {
            //ログインしていない場合、ログイン推奨ページに遷移
            let recLoginVC = storyboard?.instantiateViewController(withIdentifier: "RecLogin") as! RecommendLoginViewController
            
            self.navigationController?.pushViewController(recLoginVC, animated: true)
            
            
            //ログ
            AnalyticsUtil.sendAction(ActionEvent(screenName: .comedianDetailVC,
                                                         actionType: .tap,
                                                 actionLabel: .template(ActionLabelTemplate.comedianStockRecLoginPush)))

            
        } else {
            
            
            self.indicator.startAnimating()

            
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
                        print("documentID:\(documentID)")
                        
                    }
                    
                    //ドキュメントidがnilの場合、trueでレコードを作り画像を保存済みに更新する
                    if documentID == nil {
                        //レコード保存
                        let stockRef = Firestore.firestore().collection("stock").document()
                        let stockDic = [
                            "user_id": Auth.auth().currentUser?.uid,
                            "comedian_id": self.comedianId,
                            "comedian_display_name": self.comedianDisplayName,
                            "valid_flag": true,
                            "create_datetime": FieldValue.serverTimestamp(),
                            "update_datetime": FieldValue.serverTimestamp(),
                            "delete_flag": false,
                            "delete_datetime": nil,
                        ] as [String : Any?]
                        stockRef.setData(stockDic as [String : Any])
                        
                        self.stockButton.setImage(self.existStockButtonImage, for: .normal)
                        
                        self.db.collection("stock").whereField("comedian_id", isEqualTo: self.comedianId).whereField("valid_flag", isEqualTo: true).getDocuments() {(querySnapshot, err) in
                            
                            if let err = err {
                                print("Error getting documents: \(err)")
                                return
                                
                            } else {
                                
                                self.stockCountLabel.text = "\(querySnapshot!.documents.count)"
                                
                            }
                            
                        }
                        
                        self.stockButton.backgroundColor = #colorLiteral(red: 1, green: 0.9310497734, blue: 0.695790851, alpha: 1)
                        self.stockImageView.tintColor = #colorLiteral(red: 0.6666666865, green: 0.6238060739, blue: 0.6320286928, alpha: 1)
                        self.stockCountLabel.tintColor = #colorLiteral(red: 0.6666666865, green: 0.6238060739, blue: 0.6320286928, alpha: 1)
                        
                        
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
                            
                            self.stockButton.backgroundColor = #colorLiteral(red: 1, green: 0.9310497734, blue: 0.695790851, alpha: 1)
                            self.stockImageView.tintColor = #colorLiteral(red: 0.6666666865, green: 0.6238060739, blue: 0.6320286928, alpha: 1)
                            self.stockCountLabel.tintColor = #colorLiteral(red: 0.6666666865, green: 0.6238060739, blue: 0.6320286928, alpha: 1)
                            
                        } else {
                            
                            let existStockRef = Firestore.firestore().collection("stock").document(documentID!)
                            existStockRef.updateData([
                                "valid_flag": false,
                                "update_datetime": FieldValue.serverTimestamp(),
                            ])
                            self.stockButton.setImage(self.defaltStockButtonImage, for: .normal)
                            
                            self.stockButton.backgroundColor = #colorLiteral(red: 1, green: 0.8525225841, blue: 0.1762744927, alpha: 1)
                            self.stockImageView.tintColor = #colorLiteral(red: 0.3700678761, green: 0.3700678761, blue: 0.3700678761, alpha: 1)
                            self.stockCountLabel.tintColor = #colorLiteral(red: 0.3700678761, green: 0.3700678761, blue: 0.3700678761, alpha: 1)

                        }
                        
                        self.db.collection("stock").whereField("comedian_id", isEqualTo: self.comedianId).whereField("valid_flag", isEqualTo: true).getDocuments() {(querySnapshot, err) in
                            
                            if let err = err {
                                print("Error getting documents: \(err)")
                                return
                                
                            } else {
                                
                                self.stockCountLabel.text = "\(querySnapshot!.documents.count)"
                                
                            }
                            
                        }
                        
                        
                    }
                }
            }
            
        }
        
        //ログ
        AnalyticsUtil.sendAction(ActionEvent(screenName: .comedianDetailVC,
                                                     actionType: .tap,
                                             actionLabel: .template(ActionLabelTemplate.stockButtonTap)))
        
        self.indicator.stopAnimating()


    }
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("reviewIdArray.count:\(reviewIdArray.count)")
        
        return reviewIdArray.count
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ComedianReviewTableViewCell
        
        
        //レビューしたユーザーのユーザーIDを入れる変数
        var reviewUserId :String = ""
        //レビューしたユーザーのユーザー名を入れる変数
        var reviewUserName :String = ""
        
        //reviewidを入れる変数
        self.reviewId = self.reviewIdArray[indexPath.row]
                
        //alertボタンをセット
        cell.alertButton.addTarget(self, action: #selector(self.tappedAlertButton), for: .touchUpInside)

        
        //※プロフィール画像の仕様が決まったらここに追加する(reviewUserIdArryがあるのでそれを使う)
        //ユーザー名
        
        cell.userNameButton.tag = indexPath.row
        reviewUserName = reviewUserNameArray[indexPath.row]
        
        cell.userNameButton.contentHorizontalAlignment = .left
        cell.userNameButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
        cell.userNameButton.setTitle("　" + reviewUserName, for: .normal)

        cell.userNameButton.addTarget(self, action: #selector(self.tappedUserNameButton(sender:)), for: .touchUpInside)

        
        
        //ユーザーID
        reviewUserId = reviewDisplayIdArray[indexPath.row]
        cell.userIdLabel.text = "@" + reviewUserId
        
        
        
        cell.createdLabel.text = self.reviewCreatedArray[indexPath.row]
        
        
        //scoreをセット
        if self.reviewScoreArray[indexPath.row] == nil {
            cell.scoreImageView.image = UIImage(named: "noScored")
        } else {
            cell.scoreLabel.text = self.reviewScoreArray[indexPath.row]
            cell.scoreImageView.image = UIImage(named: "score_\(self.reviewScoreArray[indexPath.row])")
        }
        
        //行間を設定
        cell.commentLabel.text = self.reviewCommentArray[indexPath.row]
        cell.commentLabel.attributedText = cell.commentLabel.text?.attributedString(lineSpace: 5)
        cell.commentLabel.font = cell.commentLabel.font.withSize(13)
        cell.commentLabel.tintColor = UIColor.darkGray
        cell.commentLabel.textAlignment = NSTextAlignment.left
        
        
        
        //likeButtonをセット
        cell.likeButton.tag = indexPath.row
        cell.likeButton.addTarget(self, action: #selector(tappedLikeButton(sender:)), for: .touchUpInside)
        
        
        
        
        //likereviewをセット
        cell.likeCountButton.tag = indexPath.row
        cell.likeCountButton.addTarget(self, action: #selector(tappedLikeCountButton(sender:)), for: .touchUpInside)

        
        db.collection("like_review").whereField("review_id", isEqualTo: reviewId).whereField("like_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                //like_reviewドキュメントが0件の場合
                if querySnapshot!.documents.count == 0 {
                    
                    cell.likeCountButton.contentHorizontalAlignment = .left
                    cell.likeCountButton.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
                    cell.likeCountButton.setTitle("いいね！はまだありません", for: .normal)

                    cell.likeButton.setImage(self.unLikeImage, for: .normal)
                    
                } else {
                    
                    cell.likeCountButton.contentHorizontalAlignment = .left
                    cell.likeCountButton.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
                    cell.likeCountButton.setTitle("\(querySnapshot!.documents.count)件のいいね！", for: .normal)

                    //自分のlike_frag==trueのレビュー有無でレビューボタンの色を変える
                    self.db.collection("like_review").whereField("review_id", isEqualTo: self.reviewId).whereField("like_user_id", isEqualTo: self.currentUser?.uid as Any).whereField("like_flag", isEqualTo: true).getDocuments() { [self](querySnapshot, err) in
                        
                        if let err = err {
                            print("Error getting documents: \(err)")
                            return
                            
                        } else {
                            
                            if querySnapshot!.documents.count == 0 {
                                
                                cell.likeButton.setImage(self.unLikeImage, for: .normal)
                                
                            } else {
                                
                                cell.likeButton.setImage(self.likeImage, for: .normal)
                                
                            }
                            
                            
                        }
                    }                    
                    
                }
            }
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //セルタップでレビュー全文に遷移
        let allReviewVC = storyboard?.instantiateViewController(withIdentifier: "AllReview") as! AllReviewViewController
        
        allReviewVC.reviewId = self.reviewIdArray[indexPath.row]
        self.navigationController?.pushViewController(allReviewVC, animated: true)
        
    }
    
    //ユーザーネームタップでプロフィールページに遷移
    @objc func tappedUserNameButton(sender: UIButton) {
        
        let buttonTag = sender.tag
        let tappedUserId = self.reviewUserIdArray[buttonTag]
        let tappedUserName = self.reviewUserNameArray[buttonTag]

        
        let button = sender
        let cell = button.superview?.superview as! ComedianReviewTableViewCell

        
        //セルタップでプロフィールに遷移
        let profileVC = storyboard?.instantiateViewController(withIdentifier: "ProfileTab") as! ProfilePageTabViewController

        profileVC.userId = tappedUserId
        profileVC.userName = tappedUserName

        
        
        self.navigationController?.pushViewController(profileVC, animated: true)

        
    }
    
    
    
    @objc func tappedLikeButton(sender: UIButton) {
        
        
        let buttonTag = sender.tag
        let tappedReviewId = self.reviewIdArray[buttonTag]
        
        let button = sender
        let cell = button.superview?.superview as! ComedianReviewTableViewCell
        
        if currentUser?.uid == nil {
            //ログインしていない場合、ログイン推奨ページに遷移
            let recLoginVC = storyboard?.instantiateViewController(withIdentifier: "RecLogin") as! RecommendLoginViewController
            
            self.navigationController?.pushViewController(recLoginVC, animated: true)
            
            
            //ログ
            AnalyticsUtil.sendAction(ActionEvent(screenName: .comedianDetailVC,
                                                         actionType: .tap,
                                                 actionLabel: .template(ActionLabelTemplate.comedianLikeReviewReLoginPush)))

        } else {
            
            //ボタン画像の切り替え
            
            if cell.likeButton.imageView?.image == self.likeImage {
                
                cell.likeButton.setImage(self.unLikeImage, for: .normal)

            }
            
            if cell.likeButton.imageView?.image == self.unLikeImage {
                
                cell.likeButton.setImage(self.likeImage, for: .normal)

            }

            //like_reviewにセットする項目
            var documentId :String?
            var likeFlag :Bool?
            var likeUserDisplayId :String?
            var reviewUserId :String?
            var reviewUserName :String?
            var reviewUserDisplayId :String?
            var reviewComment :String?
            var reviewScore :Float?
            
            
            
            //likeしていない状態の場合
            //即ち、review_id=reviewIdArray[indexPath.row]かつuser_id=currentUserのlikeReviewレコードがないもしくは、review_id=reviewIdArray[indexPath.row]かつuser_id=currentUserのlikeReviewレコードのlike_flag==falseである場合,likereviewレコードがtrueで追加され、画像がlike済みのものに切り替わる（cellのクラス側で設定）
            
            //likeしている状態の場合
            //likereviewレコードのflagがfalseになり、画像がlike前のものに切り替わる（cellのクラス側で設定）
            
            db.collection("user_detail").whereField("user_id", isEqualTo: currentUser?.uid as Any).getDocuments() {(querySnapshot, err) in
                
                if let err = err {
                    print("Error getting documents: \(err)")
                    return
                    
                } else {
                    
                    for document in querySnapshot!.documents{
                        
                        print("userDetailDocument:\(document.data())")
                        
                        
                        likeUserDisplayId = document.data()["display_id"] as? String
                        
                        print("likeUserDisplayId:\(likeUserDisplayId)")
                        
                        
                        
                    }
                }
            }
            
            print("tappedReviewId:\(tappedReviewId)")
            
            
            //対象のreviewからlike_reviewに保存したい情報を取得
            db.collection("review").whereField(FieldPath.documentID(), isEqualTo: tappedReviewId).getDocuments() {(querySnapshot, err) in
                
                if let err = err {
                    print("Error getting documents: \(err)")
                    return
                    
                } else {

                    
                    for document in querySnapshot!.documents{
                        
                        print("reviewDocument:\(document.data())")
                        
                        reviewUserId = document.data()["user_id"] as? String
                        reviewUserName = document.data()["user_name"] as? String
                        reviewUserDisplayId = document.data()["display_id"] as? String
                        reviewComment = document.data()["comment"] as? String
                        reviewScore = document.data()["score"] as? Float

                        
                        //すでに自分がいいねしたことがあるレビューかどうかをチェック
                        self.db.collection("like_review").whereField("review_id", isEqualTo: tappedReviewId).whereField("like_user_id", isEqualTo: self.currentUser?.uid as Any).getDocuments() {(querySnapshot, err) in
                            
                            if let err = err {
                                print("Error getting documents: \(err)")
                                return
                                
                            } else {
                                //該当のlike_reviewドキュメントが0件の場合、trueでレコードを作る
                                if querySnapshot!.documents.count == 0 {
                                    
                                    //レコード保存
                                    let likeReviewRef = Firestore.firestore().collection("like_review").document()
                                    let likeReviewDic = [
                                        "review_id": tappedReviewId,
                                        "review_user_id": reviewUserId,
                                        "review_user_name": reviewUserName,
                                        "review_user_display_id": reviewUserDisplayId,
                                        "review_comment": reviewComment,
                                        "review_score": reviewScore,
                                        "like_user_id": Auth.auth().currentUser?.uid,
                                        "like_user_display_id": likeUserDisplayId,
                                        "like_user_name": Auth.auth().currentUser?.displayName,
                                        "like_flag": true,
                                        "create_datetime": FieldValue.serverTimestamp(),
                                        "update_datetime": FieldValue.serverTimestamp(),
                                        "delete_flag": false,
                                        "delete_datetime": nil,
                                    ] as [String : Any?]
                                    
                                    print("likeReviewDic:\(likeReviewDic)")
                                    likeReviewRef.setData(likeReviewDic as [String : Any])
                                    
                                    print("Successed:like_review create")
                                    
                                    //ログ
                                    AnalyticsUtil.sendAction(ActionEvent(screenName: .comedianDetailVC,
                                                                                 actionType: .tap,
                                                                         actionLabel: .template(ActionLabelTemplate.comedianLikeReviewTap)))
                                    
                                } else {
                                    
                                    for document in querySnapshot!.documents {

                                        documentId = document.documentID
                                        likeFlag = document.data()["like_flag"] as? Bool
                                        
                                    }
                                    //ドキュメントが既存の場合、flagを確認
                                    //flag=falseの場合、trueに更新
                                    
                                    print("like_reviewのdocumentId:\(documentId)")
                                    print("likeFlag:\(likeFlag)")
                                    
                                    
                                    if likeFlag == false {
                                        
                                        
                                        let existlikeReviewRef = Firestore.firestore().collection("like_review").document(documentId!)
                                        existlikeReviewRef.updateData([
                                            "review_user_name": reviewUserName as Any,
                                            "review_user_display_id": reviewUserDisplayId as Any,
                                            "review_comment": reviewComment as Any,
                                            "review_score": reviewScore as Any,
                                            "like_user_display_id": likeUserDisplayId as Any,
                                            "like_user_name": Auth.auth().currentUser?.displayName as Any,
                                            "like_flag": true,
                                            "update_datetime": FieldValue.serverTimestamp(),
                                        ])
                                        
                                    } else {

                                        
                                        let existlikeReviewRef = Firestore.firestore().collection("like_review").document(documentId!)
                                        existlikeReviewRef.updateData([
                                            "review_user_name": reviewUserName as Any,
                                            "review_user_display_id": reviewUserDisplayId as Any,
                                            "review_comment": reviewComment as Any,
                                            "review_score": reviewScore as Any,
                                            "like_user_display_id": likeUserDisplayId as Any,
                                            "like_user_name": Auth.auth().currentUser?.displayName as Any,
                                            "like_flag": false,
                                            "update_datetime": FieldValue.serverTimestamp(),
                                        ])
                                    }
                                }
                                //紐づくtrueのlike_reviewの件数をチェックしてラベルに反映
                                self.db.collection("like_review").whereField("review_id", isEqualTo: tappedReviewId).whereField("like_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
                                    
                                    if let err = err {
                                        print("Error getting documents: \(err)")
                                        return
                                        
                                    } else {
                                        
                                        //like_reviewの件数のラベル(cellで使用する)
                                        if querySnapshot!.documents.count == 0 {
                                            cell.likeCountButton.contentHorizontalAlignment = .left
                                            cell.likeCountButton.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
                                            cell.likeCountButton.setTitle("いいね！はまだありません", for: .normal)

                                        } else {
                                            cell.likeCountButton.contentHorizontalAlignment = .left
                                            cell.likeCountButton.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
                                            cell.likeCountButton.setTitle("\(querySnapshot!.documents.count)件のいいね！", for: .normal)
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
    
    //いいね欄タップでfollowVCに遷移
    @objc func tappedLikeCountButton(sender: UIButton) {
        
        
        let buttonTag = sender.tag
        let tappedReviewId = self.reviewIdArray[buttonTag]
        
        let button = sender
        let cell = button.superview?.superview as! ComedianReviewTableViewCell
        
        //セルタップでレビュー全文に遷移
        let followVC = storyboard?.instantiateViewController(withIdentifier: "FollowUser") as! FollowUserViewController
        
        followVC.reviewId = tappedReviewId
        followVC.userType = "likeReview"
        self.navigationController?.pushViewController(followVC, animated: true)
        
        
    }
    
    //alertボタンタップ時
    @objc func tappedAlertButton() {
        
        
        //UIAlertControllerを用意する
        let actionAlert = UIAlertController(title: "不適切なレビューの報告", message: "このレビューを報告しますか？", preferredStyle: UIAlertController.Style.actionSheet)
        
        //UIAlertControllerに報告のアクションを追加する
        let kabigonAction = UIAlertAction(title: "報告する", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            
            let inquiryVC = self.storyboard?.instantiateViewController(withIdentifier: "Inquiry") as! InquiryViewController
            self.navigationController?.pushViewController(inquiryVC, animated: true)

        })
        actionAlert.addAction(kabigonAction)
        
        
        //UIAlertControllerにキャンセルのアクションを追加する
        let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: {
            (action: UIAlertAction!) in

            return
        })
        actionAlert.addAction(cancelAction)
        
        //アクションを表示する
        present(actionAlert, animated: true, completion: nil)


        
    }

    
    
}

extension UIImage {
    // Firebase URLからUIImage取得
    static func contentOfFIRStorage(path: String, callback: @escaping (UIImage?) -> Void) {
        let storage = Storage.storage()
        let host = "gs://owaraiapp-f80fd.appspot.com/comedian_image/"
        storage.reference(forURL: host).child(path)
            .getData(maxSize: 1024 * 1024 * 10) { (data: Data?, error: Error?) in
            if error != nil {
                callback(nil)
                return
            }
            if let imageData = data {
                let image = UIImage(data: imageData)
                callback(image)
            }
        }
    }
    
    func resizeUIImageRatio(ratio: CGFloat) -> UIImage! {
        
        // 指定された画像の大きさのコンテキストを用意.
        UIGraphicsBeginImageContextWithOptions(CGSize(width: ratio, height: ratio - 50), false, 0.0)
        //UIGraphicsBeginImageContext(CGSize(width: ratio, height: ratio - 50))
        
        // コンテキストに自身に設定された画像を描画する.
        self.draw(in: CGRect(x: 0, y: 0, width: ratio, height: ratio - 50))
        
        // コンテキストからUIImageを作る.
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // コンテキストを閉じる.
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

extension String {
    func attributedString(
        _ color: UIColor = UIColor.black,
        font: UIFont = UIFont.systemFont(ofSize: 20),
        align: NSTextAlignment = .center,
        lineSpace: CGFloat = 10,
        kern: CGFloat = 0
    ) -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = lineSpace
        paragraph.alignment = align
        
        return NSAttributedString(string: self, attributes: [
            NSAttributedString.Key.paragraphStyle: paragraph,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.kern: kern,
        ])
    }
}
