//
//  CampaignViewController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/10/19.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class CampaignViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerButton: UIButton!
    @IBOutlet weak var bannerImageView: UIImageView!
    
    
    let db = Firestore.firestore()
    let currentUser = Auth.auth().currentUser
    

    //キャンペーン情報
    var campaignTitle :String = ""
    var campaignBannerUrl :String = ""
    var campaignHastag :String = ""

    
    
    var reviewIdArray: [String] = []
    var comedianIdArray: [String] = []
    var comedianNameArray: [String] = []
    var userIdArray: [String] = []
    var userNameArray: [String] = []
    var userDisplayIdArray: [String] = []
    var reviewUpdateDatetimeArray: [String] = []
    var reviewScoreArray: [String] = []
    var reviewCommentArray: [String] = []
    var reviewRelationalArray: [String] = []
    
    var reviewLinkArray: [String] = []
    
    var reviewId :String = ""
    
    //いいねボタン用の画像
    let likeImage = UIImage(systemName: "heart.fill")
    let unLikeImage = UIImage(systemName: "heart")
    
    //画像のパス
//    let storage = Storage.storage(url:"gs://owaraiapp-f80fd.appspot.com").reference()
    
    // インジゲーターの設定
    var indicator = UIActivityIndicatorView()
    
    //更新処理用
    let semaphore = DispatchSemaphore(value: 1)
    
    override func viewDidLoad() {
        
        // 表示位置を設定（画面中央）
        self.indicator.center = view.center
        // インジケーターのスタイルを指定（白色＆大きいサイズ）
        self.indicator.style = .large
        // インジケーターの色を設定（青色）
        self.indicator.color = UIColor.darkGray
        // インジケーターを View に追加
        view.addSubview(indicator)
        
        
        
        self.indicator.startAnimating()
        
        
        super.viewDidLoad()
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: "NewReviewTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "NewReviewCell")
        
        if #available(iOS 15.0, *) {
            self.bannerButton.configuration = nil

        }
        self.bannerButton.setTitle("", for: .normal)

        
        self.dataRefresh()
        
        self.tableView.refreshControl = UIRefreshControl()
        //        self.refreshControl.attributedTitle = NSAttributedString(string: "読み込み中")
        self.tableView.refreshControl?.addTarget(self, action: #selector(dataRefresh), for: .valueChanged)
        //        tableView.addSubview(refreshControl)
        
        
        
        
        self.indicator.stopAnimating()
        
        
    }
        
    
    @objc func dataRefresh() {
        
        
        self.campaignTitle = ""
        self.campaignBannerUrl = ""
        self.campaignHastag = ""

        
        
        self.reviewIdArray = []
        self.comedianIdArray = []
        self.comedianNameArray = []
        self.userIdArray = []
        self.userNameArray = []
        self.userDisplayIdArray = []
        self.reviewUpdateDatetimeArray = []
        self.reviewScoreArray = []
        self.reviewCommentArray = []
        self.reviewRelationalArray = []
        
        self.reviewLinkArray = []
        
        self.reviewId = ""

        
        
        self.db.collection("campaign").whereField("valid_flag", isEqualTo: true).getDocuments() { (querySnapshot, err) in
            
            if let err = err {
                
                print("faild_getCampaign: \(err)")
                return

                
            } else {
                for document in querySnapshot!.documents {
                    
                    self.campaignTitle = document.data()["title"] as! String
                    self.campaignBannerUrl = document.data()["banner_url"] as! String
                    self.campaignHastag = document.data()["hashtag"] as! String
                    
                    print("campaignTitle:\(self.campaignTitle)")
                    
                }
                
//                let imageRef = self.storage.child("campaign_banner/\(self.campaignTitle).jpg")
//                self.bannerImageView.sd_setImage(with: imageRef)
//                self.bannerImageView.contentMode = .scaleAspectFit
//                self.bannerImageView.clipsToBounds = true

                
                //キャンペーンに該当するレビューをセット
                self.db.collection("review").whereField("private_flag", isEqualTo: false).whereField("delete_flag", isEqualTo: false).whereField("campaign_flag", isEqualTo: self.campaignHastag).order(by: "update_datetime", descending: true).getDocuments() { [self] (querySnapshot, err) in
                    
                    if let err = err {
                        print("Error getting documents: \(err)")
                        return
                        
                    } else {

                        for document in querySnapshot!.documents {
                            
                            
                            self.reviewIdArray.append(document.documentID)
                            self.comedianIdArray.append(document.data()["comedian_id"] as! String)
                            self.comedianNameArray.append(document.data()["comedian_display_name"] as! String)
                            self.userIdArray.append(document.data()["user_id"] as! String)
                            self.userNameArray.append(document.data()["user_name"] as! String)
                            
                            self.userDisplayIdArray.append(document.data()["display_id"] as! String)
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateStyle = .short
                            dateFormatter.timeStyle = .short
                            dateFormatter.locale = Locale(identifier: "ja_JP")
                            
                            dateFormatter.dateFormat = "yyyy/MM/dd hh:mm"
                            
                            let updated = document.data()["update_datetime"] as! Timestamp
                            let updatedDate = updated.dateValue()
                            let updatedDateTime = dateFormatter.string(from: updatedDate)
                            self.reviewUpdateDatetimeArray.append(updatedDateTime)
                            
                            let reviewFloatScoreArray = document.data()["score"] as! Float
                            self.reviewScoreArray.append(String(reviewFloatScoreArray))
                            
                            self.reviewCommentArray.append(document.data()["comment"] as! String)
                            
                            
                            
                            self.reviewRelationalArray.append(document.data()["relational_comedian_listname"] as! String)
                        }
                        
                        self.tableView.reloadData()
                        print("reviewScoreArray:\(reviewScoreArray)")
                        
                        
                        
                        self.tableView.refreshControl?.endRefreshing()
                        
                        
                    }
                }
            }
        }
    }

    @IBAction func tappedBanner(_ sender: Any) {
        
        print("キャンペーンURL：\(self.campaignBannerUrl)")
        let url = URL(string: "\(self.campaignBannerUrl)")
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!)
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("self.reviewIdArray.count:\(self.reviewIdArray.count)")
        return self.reviewIdArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 370
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewReviewCell", for: indexPath) as! NewReviewTableViewCell
        cell.tag = indexPath.row
        
        cell.userNameButton.tag = indexPath.row
        cell.userNameButton.contentHorizontalAlignment = .left
        cell.userNameButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
        cell.userNameButton.setTitle("　" + self.userNameArray[indexPath.row], for: .normal)
        cell.userNameButton.addTarget(self, action: #selector(self.tappedUserNameButton(sender:)), for: .touchUpInside)
        
        cell.userDisplayIdLabel.text = "　@" + self.userDisplayIdArray[indexPath.row] + " - " + self.reviewUpdateDatetimeArray[indexPath.row]
        
        cell.comedianNameButton.tag = indexPath.row
        cell.comedianNameButton.addTarget(self, action: #selector(tappedcomedianButton(sender:)), for: .touchUpInside)
        
        cell.comedianNameButton.contentHorizontalAlignment = .left
        cell.comedianNameButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        cell.comedianNameButton.setTitle("　" + self.comedianNameArray[indexPath.row], for: .normal)
        
        cell.scoreLabel.text = self.reviewScoreArray[indexPath.row]
        cell.scoreImageView.image = UIImage(named: "score_\(self.reviewScoreArray[indexPath.row])")
        
        cell.likeCountButton.tag = indexPath.row
        
        cell.commentLabel.tag = indexPath.row
        cell.commentLabel.text = self.reviewCommentArray[indexPath.row]
        
        
        cell.commentLabel.attributedText = cell.commentLabel.text?.attributedString(lineSpace: 5)
        cell.commentLabel.font = cell.commentLabel.font.withSize(13)
        cell.commentLabel.tintColor = UIColor.darkGray
        cell.commentLabel.textAlignment = NSTextAlignment.left
        
        
        //        //コメントのリンクをセット
        //        cell.reviewCommentLink.tag = indexPath.row
        //        cell.reviewCommentLink.text = self.reviewLinkArray[indexPath.row]
        
        
        //        //タップ時の操作を付与する
        //        cell.commentLabel.isUserInteractionEnabled = true
        //        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapReviewLinkGesture))
        //        cell.commentLabel.addGestureRecognizer(tapGestureRecognizer)
        
        
        
        //copyrightflagを取得して画像をセット
        db.collection("comedian").whereField(FieldPath.documentID(), isEqualTo: self.comedianIdArray[indexPath.row]).getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                for document in querySnapshot!.documents {
                    
                    let copyrightFlag = document.data()["copyright_flag"] as! String
                    
                    if copyrightFlag == "true" {
                        
                        //                        let imageRef = self.storage.child("comedian_image/\(self.comedianIdArray[indexPath.row]).jpg")
                        //                        cell.comedianImageView.sd_setImage(with: imageRef, placeholderImage: UIImage(named: "noImage"))
                        
                        cell.comedianImageView.image = UIImage(named: "\(self.comedianIdArray[indexPath.row])")
                        //                        cell.comedianImageView.contentMode = .scaleAspectFill
                        //                        cell.comedianImageView.clipsToBounds = true
                        
                        
                    }
                    
                    if copyrightFlag == "false" {
                        
                        cell.comedianImageView.image = UIImage(named: "noImage")
                        
                    }
                }
            }
        }
        
        //relationalcomedianがいる場合はセット、いない場合は空白
        
        if self.reviewRelationalArray[indexPath.row] == "" {
            
            cell.beforeRelationalLabel.text = ""
            cell.relationalComedianLabel.text = ""
            cell.afterRelationalLabel.text = ""
            
        }
        
        if self.reviewRelationalArray[indexPath.row] != "" {
            
            cell.beforeRelationalLabel.text = "この芸人さんは"
            cell.relationalComedianLabel.text = self.reviewRelationalArray[indexPath.row]
            cell.afterRelationalLabel.text = "が好きな人にハマりそう！"
            
        }
        
        
        //likeButtonをセット
        cell.likeButton.tag = indexPath.row
        cell.likeButton.addTarget(self, action: #selector(tappedLikeButton(sender:)), for: .touchUpInside)
        
        //likereviewをセット
        
        cell.likeCountButton.addTarget(self, action: #selector(tappedLikeCountButton(sender:)), for: .touchUpInside)
        
        
        db.collection("like_review").whereField("review_id", isEqualTo: self.reviewIdArray[indexPath.row]).whereField("like_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
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
                    self.db.collection("like_review").whereField("review_id", isEqualTo: self.reviewIdArray[indexPath.row]).whereField("like_user_id", isEqualTo: self.currentUser?.uid as Any).whereField("like_flag", isEqualTo: true).getDocuments() { [self](querySnapshot, err) in
                        
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
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        
        
    }
    
    @objc func tappedLikeButton(sender: UIButton) {
        
        
        let buttonTag = sender.tag
        let tappedReviewId = self.reviewIdArray[buttonTag]
        
        let button = sender
        let cell = button.superview?.superview as! NewReviewTableViewCell
        
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
                                            
                                            cell.likeButton.setImage(self.unLikeImage, for: .normal)
                                            
                                            
                                            
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
    //芸人名タップでcomedianDetailに遷移
    @objc func tappedcomedianButton(sender: UIButton) {
        
        
        let buttonTag = sender.tag
        let tappedComedianId = self.comedianIdArray[buttonTag]
        
        let button = sender
        let cell = button.superview?.superview as! NewReviewTableViewCell
        
        //セルタップでレビュー全文に遷移
        let comedianVC = storyboard?.instantiateViewController(withIdentifier: "Comedian") as! ComedianDetailViewController
        
        comedianVC.comedianId = tappedComedianId
        self.navigationController?.pushViewController(comedianVC, animated: true)
        
        
    }
    
    //いいね欄タップでfollowVCに遷移
    @objc func tappedLikeCountButton(sender: UIButton) {
        
        
        let buttonTag = sender.tag
        let tappedReviewId = self.reviewIdArray[buttonTag]
        
        let button = sender
        let cell = button.superview?.superview as! NewReviewTableViewCell
        
        //セルタップでレビュー全文に遷移
        let followVC = storyboard?.instantiateViewController(withIdentifier: "FollowUser") as! FollowUserViewController
        
        followVC.reviewId = tappedReviewId
        followVC.userType = "likeReview"
        self.navigationController?.pushViewController(followVC, animated: true)
        
        
    }
    
    
    
    
    //ユーザーネームタップでプロフィールページに遷移
    
    @objc func tappedUserNameButton(sender: UIButton) {
        
        let buttonTag = sender.tag
        let tappedUserId = self.userIdArray[buttonTag]
        let tappedUserName = self.userNameArray[buttonTag]
        
        
        let button = sender
        let cell = button.superview?.superview as! NewReviewTableViewCell
        
        
        
        //セルタップでプロフィールに遷移
        let profileVC = storyboard?.instantiateViewController(withIdentifier: "ProfileTab") as! ProfilePageTabViewController
        
        profileVC.userId = tappedUserId
        profileVC.userName = tappedUserName
        
        
        
        self.navigationController?.pushViewController(profileVC, animated: true)
        
        
    }
    
}
