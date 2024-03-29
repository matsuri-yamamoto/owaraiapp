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
    
    
    var reviewId :String = ""
    
    //Firestoreを使うための下準備
    let currentUser = Auth.auth().currentUser
    let db = Firestore.firestore()
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
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
        
        
        
        
        //レビューボタンの画像を設定
        
        //reviewドキュメントからscoreを参照
        //reviewのtableViewにセットする配列を作る(userName,displayId,create_datetime,score,comment)
        
        //reviewのtimestamp型、number型のデータを取得するためのデータ型変換用
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "ja_JP")
        
        
        
        db.collection("review").whereField("comedian_id", isEqualTo: comedianId).whereField("private_flag", isEqualTo: false).whereField("delete_flag", isEqualTo: false).order(by: "create_datetime", descending: true).getDocuments() {(querySnapshot, err) in
            
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
                    
                    
                    //レビューを配列で取得(別画面から戻る場合などにレビュー×2が読み込まれてしまうので、一旦仮の配列に入れてあとでユニークにする)
                    self.reviewBeforeUniqueArray.append(document.documentID)
                    print("self.reviewBeforeUniqueArray:\(self.reviewBeforeUniqueArray)")
                    
                    
                    //以下、reviewのtableViewにセットする配列
                    //レビューをユニークにする
                    var reviewId = Set<String>()
                    self.reviewIdArray = self.reviewBeforeUniqueArray.filter { reviewId.insert($0).inserted }

                    
                    
                    
                    
                    self.reviewUserNameArray.append(document.data()["user_name"] as! String)
                    self.reviewDisplayIdArray.append(document.data()["display_id"] as! String)
                    
                    //一旦FSのtimestampでデータを呼ぶ
                    let reviewCreatedDate = document.data()["create_datetime"] as! Timestamp
                    //Swiftのdateに変換
                    reviewCreatedDate.dateValue()
                    self.reviewCreatedArray.append(dateFormatter.string(from: reviewCreatedDate.dateValue()))
                    
                    self.reviewScoreArray.append(String(document.data()["score"] as! Float))
                    self.reviewCommentArray.append(document.data()["comment"] as! String)
                    
                    self.tableView.reloadData()
                    
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
            }
        }
        
        //pvログ
        AnalyticsUtil.sendScreenName(ScreenEvent(screenName: .comedianDetailVC))
        
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 250
        
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
            
            hidesBottomBarWhenPushed = true
            
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
            
            //comedianNameLabelをStringに変換して芸人名を渡す
            var comedianName = comedianNameLabel.text! as String
            reviewVC.comedianName = comedianName
            
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
            
            hidesBottomBarWhenPushed = true
            
            //ログ
            AnalyticsUtil.sendAction(ActionEvent(screenName: .comedianDetailVC,
                                                         actionType: .tap,
                                                 actionLabel: .template(ActionLabelTemplate.comedianStockRecLoginPush)))

            
        } else {
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
                
        
        //※プロフィール画像の仕様が決まったらここに追加する(reviewUserIdArryがあるのでそれを使う)
        //ユーザー名
        reviewUserName = reviewUserNameArray[indexPath.row]
        cell.userNameLabel.text = reviewUserName
        
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
        cell.commentLabel.text = self.reviewCommentArray[indexPath.row]
        
        
        //likeButtonをセット
        cell.likeButton.tag = indexPath.row
        cell.likeButton.addTarget(self, action: #selector(tappedLikeButton(sender:)), for: .touchUpInside)
        
        
        
        
        //likereviewをセット
        db.collection("like_review").whereField("review_id", isEqualTo: reviewId).whereField("like_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                //like_reviewドキュメントが0件の場合
                if querySnapshot!.documents.count == 0 {
                    cell.likeCountLabel.text = "いいね！はまだありません"
                } else {
                    cell.likeCountLabel.text = "\(querySnapshot!.documents.count)件のいいね！"
                    
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
    
    @objc func tappedLikeButton(sender: UIButton) {
        
        
        let buttonTag = sender.tag
        let tappedReviewId = self.reviewIdArray[buttonTag]
        
        let button = sender
        let cell = button.superview?.superview as! ComedianReviewTableViewCell
        
        if currentUser?.uid == nil {
            //ログインしていない場合、ログイン推奨ページに遷移
            let recLoginVC = storyboard?.instantiateViewController(withIdentifier: "RecLogin") as! RecommendLoginViewController
            
            self.navigationController?.pushViewController(recLoginVC, animated: true)
            
            hidesBottomBarWhenPushed = true
            
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
                                            cell.likeCountLabel.text = "いいね！はまだありません"

                                        } else {
                                            cell.likeCountLabel.text = "\(querySnapshot!.documents.count)件のいいね！"

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
}
