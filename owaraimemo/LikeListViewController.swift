//
//  LikeListViewController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/10/05.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorageUI


class LikeListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let db = Firestore.firestore()
    let currentUser = Auth.auth().currentUser
    
    @IBOutlet weak var tableView: UITableView!

    var reviewIdArray: [String] = []
    var comedianIdArray: [String] = []
    var comedianNameArray: [String] = []
    var userIdArray: [String] = []
    var userNameArray: [String] = []
    var userDisplayIdArray: [String] = []
    var reviewCreateDatetimeArray: [String] = []
    var reviewScoreArray: [String] = []
    var reviewCommentArray: [String] = []
    var reviewRelationalArray: [String] = []
    
    var reviewId :String = ""
    
    var userId :String = ""
    var userName :String = ""
    var userDisplayId :String = ""
    var comedianName :String = ""
    var comedianId :String = ""
    var updated :String = ""
    var score :String = ""
    var comment :String = ""
    var relational :String = ""

    
    //いいねボタン用の画像
    let likeImage = UIImage(systemName: "heart.fill")
    let unLikeImage = UIImage(systemName: "heart")
    
    //画像のパス
    let storage = Storage.storage(url:"gs://owaraiapp-f80fd.appspot.com").reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let nib = UINib(nibName: "NewReviewTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "NewReviewCell")
        
        
//        //自分がいいねしたreviewのidを参照する
//        self.db.collection("like_review").whereField("like_user_id", isEqualTo: currentUser?.uid).whereField("like_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).order(by: "update_datetime", descending: true).getDocuments() { (querySnapshot, err) in
//
//            if let err = err {
//                print("Error getting documents: \(err)")
//                return
//
//            } else {
//                for document in querySnapshot!.documents {
//
//                    self.reviewIdArray.append(document.data()["review_id"] as! String)
//
//
//                }
//
//                print("self.reviewIdArray:\(self.reviewIdArray)")
//
//
//
//            }
//        }
        
        self.setReviewId()

    }
    
    func setReviewId() {
        
        
        //自分がいいねしたreviewのidを参照する
        self.db.collection("like_review").whereField("like_user_id", isEqualTo: currentUser?.uid).whereField("like_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).order(by: "update_datetime", descending: true).getDocuments() { (querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                for document in querySnapshot!.documents {
                    
                    self.reviewIdArray.append(document.data()["review_id"] as! String)

                    
                }
                
                print("self.reviewIdArray:\(self.reviewIdArray)")
                
                
            }
            
            defer {
                self.tableView.reloadData()
            }

        }
        
    }
    

    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("likelist_self.reviewIdArray.count:\(self.reviewIdArray.count)")
        return self.reviewIdArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 360
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewReviewCell", for: indexPath) as! NewReviewTableViewCell

        self.reviewId = self.reviewIdArray[indexPath.row]
        print("likelist_reviewId:\(self.reviewId)")

        
        db.collection("review").whereField(FieldPath.documentID(), isEqualTo: self.reviewId).whereField("private_flag", isEqualTo: false).whereField("delete_flag", isEqualTo: false).getDocuments() { (querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                for document in querySnapshot!.documents {
                                    
                    
                    self.userId = document.data()["user_id"] as! String
                    self.comedianId = document.data()["comedian_id"] as! String
 
                    
                    self.userName = document.data()["user_name"] as! String
                    cell.userNameButton.contentHorizontalAlignment = .left
                    cell.userNameButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
                    cell.userNameButton.setTitle("　" + self.userName, for: .normal)

                    
                    self.userDisplayId = document.data()["display_id"] as! String
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .short
                    dateFormatter.timeStyle = .short
                    dateFormatter.locale = Locale(identifier: "ja_JP")
                    
                    dateFormatter.dateFormat = "yyyy/mm/dd hh:mm"
                    let updated = document.data()["update_datetime"] as! Timestamp
                    let updatedDate = updated.dateValue()
                    let updatedDateTime = dateFormatter.string(from: updatedDate)
                    self.updated = updatedDateTime

                    cell.userDisplayIdLabel.text = "　@" + self.userDisplayId + " - " + self.updated
                    
                    self.comedianName = document.data()["comedian_display_name"] as! String
                    cell.comedianNameButton.tag = indexPath.row
                    cell.comedianNameButton.addTarget(self, action: #selector(self.tappedcomedianButton(sender:)), for: .touchUpInside)

                    
                    cell.comedianNameButton.contentHorizontalAlignment = .left
                    cell.comedianNameButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
                    cell.comedianNameButton.setTitle("　" + self.comedianName, for: .normal)
                    

                    self.score = String(document.data()["score"] as! Float)
                    cell.scoreLabel.text = self.score
                    cell.scoreImageView.image = UIImage(named: "score_\(self.score)")

                    
                    self.comment = document.data()["comment"] as! String
                    cell.commentLabel.text = self.comment
                    cell.commentLabel.attributedText = cell.commentLabel.text?.attributedString(lineSpace: 5)
                    cell.commentLabel.font = cell.commentLabel.font.withSize(12)
                    cell.commentLabel.tintColor = UIColor.darkGray
                    cell.commentLabel.textAlignment = NSTextAlignment.left
                    
                    self.relational = document.data()["relational_comedian_listname"] as! String
                    
                    
                }
                
                
                
                //copyrightflagを取得して画像をセット
                self.db.collection("comedian").whereField(FieldPath.documentID(), isEqualTo: self.comedianId).getDocuments() {(querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                        return
                        
                    } else {
                        for document in querySnapshot!.documents {
                            
                            let copyrightFlag = document.data()["copyright_flag"] as! String
                            
                            if copyrightFlag == "true" {
                                
                                let imageRef = self.storage.child("comedian_image/\(self.comedianId).jpg")
                                cell.comedianImageView.sd_setImage(with: imageRef, placeholderImage: UIImage(named: "noImage"))
                                
                            }
                            
                            if copyrightFlag == "false" {
                                
                                cell.comedianImageView.image = UIImage(named: "noImage")
                                
                            }
                        }
                    }
                }
                
                //relationalcomedianがいる場合はセット、いない場合は空白
                
                if self.relational == "" {
                    
                    cell.beforeRelationalLabel.text = ""
                    cell.relationalComedianLabel.text = ""
                    cell.afterRelationalLabel.text = ""
                    
                }
                
                if self.relational != "" {
                    
                    cell.beforeRelationalLabel.text = "この芸人さんは"
                    cell.relationalComedianLabel.text = self.relational
                    cell.afterRelationalLabel.text = "が好きな人にハマりそう！"
                    
                }
                
                
                //likeButtonをセット
                cell.likeButton.tag = indexPath.row
                cell.likeButton.addTarget(self, action: #selector(self.tappedLikeButton(sender:)), for: .touchUpInside)

                //likereviewをセット
                self.db.collection("like_review").whereField("review_id", isEqualTo: self.reviewId).whereField("like_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
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
            }
        }
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //セルタップでレビュー全文に遷移
        let allReviewVC = storyboard?.instantiateViewController(withIdentifier: "AllReview") as! AllReviewViewController
        
        allReviewVC.reviewId = self.reviewIdArray[indexPath.row]
        self.navigationController?.pushViewController(allReviewVC, animated: true)
        hidesBottomBarWhenPushed = true
        
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
        hidesBottomBarWhenPushed = true
        
        
    }
    
    //ユーザーネームタップでプロフィールページに遷移
}
