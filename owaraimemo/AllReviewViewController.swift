//
//  AllReviewViewController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/09/30.
//

import UIKit
import Firebase
import FirebaseFirestore

class AllReviewViewController: UIViewController {
    
    var reviewId :String = ""
    
    let db = Firestore.firestore()
    let currentUser = Auth.auth().currentUser

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userDisplayIdLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var scoreImageView: UIImageView!
    @IBOutlet weak var likeReviewCountLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeReviewStatusLabel: UILabel!
    
    //いいねボタン用の画像
    let likeImage = UIImage(systemName: "heart.fill")
    let unLikeImage = UIImage(systemName: "heart")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //reviewの内容をセットする
        db.collection("review").whereField(FieldPath.documentID(), isEqualTo: self.reviewId).getDocuments() { (querySnapshot, err) in

            if let err = err {
                print("Error getting documents: \(err)")
                return

            } else {
                for document in querySnapshot!.documents {

                    let comedianName = document.data()["comedian_display_name"] as! String
                    self.titleLabel.text = "　" + comedianName + "の感想"
                    
                    let userName = document.data()["user_name"] as! String
                    self.userNameLabel.text = userName
                    
                    let userDisplayId = document.data()["display_id"] as! String
                    self.userDisplayIdLabel.text = "@" + userDisplayId
                    
                    let score = String(document.data()["score"] as! Float)
                    self.scoreLabel.text = score
                    self.scoreImageView.image = UIImage(named: "score_\(score)")
                    
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .short
                    dateFormatter.timeStyle = .short
                    dateFormatter.locale = Locale(identifier: "ja_JP")
                    
                    dateFormatter.dateFormat = "yyyy/mm/dd hh:mm"
                    let created = document.data()["create_datetime"] as! Timestamp
                    let createdDate = created.dateValue()
                    let createdDateTime = dateFormatter.string(from: createdDate)
                    self.createdLabel.text = createdDateTime
                    
                    let comment = document.data()["comment"] as! String
                    self.commentLabel.text = comment
                    self.commentLabel.attributedText = self.commentLabel.text?.attributedString(lineSpace: 5)
                    self.commentLabel.font = self.commentLabel.font.withSize(13)
                    self.commentLabel.tintColor = UIColor.darkGray
                    self.commentLabel.textAlignment = NSTextAlignment.left


                }

            }
        }
        
        //紐づくlike_reviewをセットする
        db.collection("like_review").whereField("review_id", isEqualTo: self.reviewId).whereField("like_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                //like_reviewドキュメントが0件の場合
                if querySnapshot!.documents.count == 0 {
                    self.likeReviewCountLabel.text = "0"
                    self.likeReviewStatusLabel.text = "いいね！はまだありません"

                } else {
                    
                    self.likeReviewCountLabel.text = "\(querySnapshot!.documents.count)"
                    self.likeReviewStatusLabel.text = "\(querySnapshot!.documents.count)件のいいね！"
                    
                    //自分のlike_frag==trueのレビュー有無でレビューボタンの色を変える
                    self.db.collection("like_review").whereField("review_id", isEqualTo: self.reviewId).whereField("like_user_id", isEqualTo: self.currentUser?.uid as Any).whereField("like_flag", isEqualTo: true).getDocuments() { [self](querySnapshot, err) in
                        
                        if let err = err {
                            print("Error getting documents: \(err)")
                            return
                            
                        } else {
                            
                            if querySnapshot!.documents.count == 0 {
                                
                                self.likeButton.setImage(self.unLikeImage, for: .normal)
                                
                            } else {
                                
                                self.likeButton.setImage(self.likeImage, for: .normal)
                                
                            }
                            
                            
                        }
                    }
                    
                }
            }
        }
        
        
    }
    
    
    @IBAction func tappedLikeButton(_ sender: Any) {
        
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
            
            if likeButton.imageView?.image == self.likeImage {
                
                likeButton.setImage(self.unLikeImage, for: .normal)

            }
            
            if likeButton.imageView?.image == self.unLikeImage {
                
                likeButton.setImage(self.likeImage, for: .normal)

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
                                                                        
                    }
                }
            }
            
            
            
            //対象のreviewからlike_reviewに保存したい情報を取得
            db.collection("review").whereField(FieldPath.documentID(), isEqualTo: self.reviewId).getDocuments() {(querySnapshot, err) in
                
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
                        self.db.collection("like_review").whereField("review_id", isEqualTo: self.reviewId).whereField("like_user_id", isEqualTo: self.currentUser?.uid as Any).getDocuments() {(querySnapshot, err) in
                            
                            if let err = err {
                                print("Error getting documents: \(err)")
                                return
                                
                            } else {
                                //該当のlike_reviewドキュメントが0件の場合、trueでレコードを作る
                                if querySnapshot!.documents.count == 0 {
                                    
                                    //レコード保存
                                    let likeReviewRef = Firestore.firestore().collection("like_review").document()
                                    let likeReviewDic = [
                                        "review_id": self.reviewId,
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
                                self.db.collection("like_review").whereField("review_id", isEqualTo: self.reviewId).whereField("like_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
                                    
                                    if let err = err {
                                        print("Error getting documents: \(err)")
                                        return
                                        
                                    } else {
                                        
                                        //like_reviewの件数のラベル(cellで使用する)
                                        if querySnapshot!.documents.count == 0 {
                                            self.likeReviewStatusLabel.text = "いいね！はまだありません"

                                        } else {
                                            self.likeReviewStatusLabel.text = "\(querySnapshot!.documents.count)件のいいね！"

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
