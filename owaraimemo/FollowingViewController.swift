//
//  FollowingViewController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/10/05.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorageUI


class FollowingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    let currentUser = Auth.auth().currentUser
    
    //いいねボタン用の画像
    let likeImage = UIImage(systemName: "heart.fill")
    let unLikeImage = UIImage(systemName: "heart")
    
    //画像のパス
//    let storage = Storage.storage(url:"gs://owaraiapp-f80fd.appspot.com").reference()
    
    var followedUserArray: [String] = []
    var followedUserArray1: [String] = []
    var followedUserArray2: [String] = []
    var followedUserArray3: [String] = []
    var followedUserArray4: [String] = []
    var followedUserArray5: [String] = []
    
    var reviewIdArray: [String] = []
    var reviewIdArray1: [String] = []
    var reviewIdArray2: [String] = []
    var reviewIdArray3: [String] = []
    var reviewIdArray4: [String] = []
    var reviewIdArray5: [String] = []

    var reviewComedianIdArray: [String] = []
    var reviewComedianIdArra1: [String] = []
    var reviewComedianIdArray2: [String] = []
    var reviewComedianIdArray3: [String] = []
    var reviewComedianIdArray4: [String] = []
    var reviewComedianIdArray5: [String] = []
    
//    var comedianIdArray: [String] = []
//    var comedianNameArray: [String] = []
//    var userIdArray: [String] = []
//    var userNameArray: [String] = []
//    var userDisplayIdArray: [String] = []
//    var reviewUpdateDatetimeArray: [String] = []
//    var reviewScoreArray: [String] = []
//    var reviewCommentArray: [String] = []
//    var reviewRelationalArray: [String] = []
    
    var userId :String = ""
    var userName :String = ""
    var userDisplayId :String = ""
    var comedianName :String = ""
    var updated :String = ""
    var score :String = ""
    var comment :String = ""
    var relational :String = ""
    var reviewId :String = ""

    var referenceUrl :String = ""


    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        let nib = UINib(nibName: "NewReviewTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "NewReviewCell")
        
        dataRefresh()
        
        
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(dataRefresh), for: .valueChanged)

        

    }
    
    
    @objc func dataRefresh() {
        
        self.followedUserArray = []
        self.followedUserArray1 = []
        self.followedUserArray2 = []
        self.followedUserArray3 = []
        self.followedUserArray4 = []
        self.followedUserArray5 = []

        self.reviewIdArray = []
        self.reviewIdArray1 = []
        self.reviewIdArray2 = []
        self.reviewIdArray3 = []
        self.reviewIdArray4 = []
        self.reviewIdArray5 = []

        
        self.reviewComedianIdArray = []
        self.reviewComedianIdArra1 = []
        self.reviewComedianIdArray2 = []
        self.reviewComedianIdArray3 = []
        self.reviewComedianIdArray4 = []
        self.reviewComedianIdArray5 = []

        
        //フォロー中のuser_idを特定する
        db.collection("follow").whereField("following_user_id", isEqualTo: currentUser?.uid).whereField("valid_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).getDocuments() { (querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                for document in querySnapshot!.documents {
                    
                    self.followedUserArray.append(document.data()["followed_user_id"] as! String)
                    print("followedUserArray:\(self.followedUserArray)")
                }
                
                if (querySnapshot?.documents.count)! == 0 {
                    

                
                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()
                    return
                    
                    
                } else if (querySnapshot?.documents.count)! <= 10 {
                    
                    self.followedUserArray1 = self.followedUserArray
                    
                    self.setReviewId()
                    
                    
                } else if (querySnapshot?.documents.count)! <= 20 {
                    
                    self.followedUserArray1 = Array(self.followedUserArray[0..<10])
                    self.followedUserArray2 = Array(self.followedUserArray[10..<20])
                    
                    self.setReviewId()

                    
                } else if (querySnapshot?.documents.count)! <= 30 {
                    
                    self.followedUserArray1 = Array(self.followedUserArray[0..<10])
                    self.followedUserArray2 = Array(self.followedUserArray[10..<20])
                    self.followedUserArray3 = Array(self.followedUserArray[20..<30])
                    
                    self.setReviewId()


                    
                } else if (querySnapshot?.documents.count)! <= 40 {
                    
                    self.followedUserArray1 = Array(self.followedUserArray[0..<10])
                    self.followedUserArray2 = Array(self.followedUserArray[10..<20])
                    self.followedUserArray3 = Array(self.followedUserArray[20..<30])
                    self.followedUserArray4 = Array(self.followedUserArray[30..<40])
                    
                    self.setReviewId()

                    
                } else if (querySnapshot?.documents.count)! <= 50 {
                    
                    self.followedUserArray1 = Array(self.followedUserArray[0..<10])
                    self.followedUserArray2 = Array(self.followedUserArray[10..<20])
                    self.followedUserArray3 = Array(self.followedUserArray[20..<30])
                    self.followedUserArray5 = Array(self.followedUserArray[40..<50])
                    
                    self.setReviewId()
                    
                }
                
            }
            


        }
        
    }
    
    
    
    
    func setReviewId() {
        

        
        print("followedUserArray1:\(self.followedUserArray1)")
        
        self.db.collection("review").whereField("user_id", in: self.followedUserArray1).whereField("private_flag", isEqualTo: false).whereField("delete_flag", isEqualTo: false).order(by: "update_datetime", descending: true).getDocuments() { [self] (querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                for document in querySnapshot!.documents {
                    
                    self.reviewIdArray1.append(document.documentID)
                    self.reviewIdArray = self.reviewIdArray1
                    print("reviewIdArray_1:\(self.reviewIdArray)")
                    
                    self.reviewComedianIdArra1.append(document.data()["comedian_id"] as! String)
                    self.reviewComedianIdArray = self.reviewComedianIdArra1
                    
                }
                
                
                if self.followedUserArray2 != [] {
                    
                    self.db.collection("review").whereField("user_id", in: self.followedUserArray2).whereField("private_flag", isEqualTo: false).whereField("delete_flag", isEqualTo: false).order(by: "update_datetime", descending: true).getDocuments() { [self] (querySnapshot, err) in
                        
                        if let err = err {
                            print("Error getting documents: \(err)")
                            return
                            
                        } else {
                            for document in querySnapshot!.documents {
                                
                                self.reviewIdArray2.append(document.documentID)
                                self.reviewIdArray += self.reviewIdArray2
                                
                                self.reviewComedianIdArray2.append(document.data()["comedian_id"] as! String)
                                self.reviewComedianIdArray += self.reviewComedianIdArray2

                                
                            }

                            
                            if self.followedUserArray3 != [] {
                                
                                self.db.collection("review").whereField("user_id", in: self.followedUserArray3).whereField("private_flag", isEqualTo: false).whereField("delete_flag", isEqualTo: false).order(by: "update_datetime", descending: true).getDocuments() { [self] (querySnapshot, err) in
                                    
                                    if let err = err {
                                        print("Error getting documents: \(err)")
                                        return
                                        
                                    } else {
                                        for document in querySnapshot!.documents {
                                            
                                            self.reviewIdArray3.append(document.documentID)
                                            self.reviewIdArray += self.reviewIdArray3
                                            
                                            self.reviewComedianIdArray3.append(document.data()["comedian_id"] as! String)
                                            self.reviewComedianIdArray += self.reviewComedianIdArray3

                                        }

                                        
                                        if self.followedUserArray4 != [] {
                                            
                                            self.db.collection("review").whereField("user_id", in: self.followedUserArray4).whereField("private_flag", isEqualTo: false).whereField("delete_flag", isEqualTo: false).order(by: "update_datetime", descending: true).getDocuments() { [self] (querySnapshot, err) in
                                                
                                                if let err = err {
                                                    print("Error getting documents: \(err)")
                                                    return
                                                    
                                                } else {
                                                    for document in querySnapshot!.documents {
                                                        
                                                        self.reviewIdArray4.append(document.documentID)
                                                        self.reviewIdArray += self.reviewIdArray4

                                                        self.reviewComedianIdArray4.append(document.data()["comedian_id"] as! String)
                                                        self.reviewComedianIdArray += self.reviewComedianIdArray4

                                                    }

                                                    
                                                    if self.followedUserArray5 != [] {
                                                        
                                                        self.db.collection("review").whereField("user_id", in: self.followedUserArray5).whereField("private_flag", isEqualTo: false).whereField("delete_flag", isEqualTo: false).order(by: "update_datetime", descending: true).getDocuments() { [self] (querySnapshot, err) in
                                                            
                                                            if let err = err {
                                                                print("Error getting documents: \(err)")
                                                                return
                                                                
                                                            } else {
                                                                for document in querySnapshot!.documents {
                                                                    
                                                                    self.reviewIdArray5.append(document.documentID)
                                                                    self.reviewIdArray += self.reviewIdArray5
                                                                    
                                                                    self.reviewComedianIdArray5.append(document.data()["comedian_id"] as! String)
                                                                    self.reviewComedianIdArray += self.reviewComedianIdArray5


                                                                    
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
                    }
                    
                }
                self.tableView.reloadData()

                
            }
            
            self.tableView.delegate = self
            self.tableView.dataSource = self
            
            self.tableView.refreshControl?.endRefreshing()
                        
        }

                
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("following>self.reviewIdArray.count:\(self.reviewIdArray.count)")
        return self.reviewIdArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 370
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewReviewCell", for: indexPath) as! NewReviewTableViewCell
        

        //alertボタンをセット
        cell.alertButton.addTarget(self, action: #selector(self.tappedAlertButton), for: .touchUpInside)

        
        db.collection("review").whereField(FieldPath.documentID(), isEqualTo: self.reviewIdArray[indexPath.row]).whereField("private_flag", isEqualTo: false).whereField("delete_flag", isEqualTo: false).getDocuments() { (querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                for document in querySnapshot!.documents {
                    
                    self.userId = document.data()["user_id"] as! String
 
                    
                    self.userName = document.data()["user_name"] as! String
                    cell.userNameButton.contentHorizontalAlignment = .left
                    cell.userNameButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
                    cell.userNameButton.setTitle("　" + self.userName, for: .normal)
//                    cell.userNameButton.addTarget(self, action: #selector(self.tappedUserNameButton(sender:)), for: .touchUpInside)
                    
                    self.userDisplayId = document.data()["display_id"] as! String
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .short
                    dateFormatter.timeStyle = .short
                    dateFormatter.locale = Locale(identifier: "ja_JP")
                    
                    dateFormatter.dateFormat = "yyyy/MM/dd hh:mm"
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
                    cell.commentLabel.font = cell.commentLabel.font.withSize(13)
                    cell.commentLabel.tintColor = UIColor.darkGray
                    cell.commentLabel.textAlignment = NSTextAlignment.left
                    
                    self.relational = document.data()["relational_comedian_listname"] as! String

                    
                }
                                                
                //copyrightflagを取得して画像をセット
                self.db.collection("comedian").whereField(FieldPath.documentID(), isEqualTo: self.reviewComedianIdArray[indexPath.row]).getDocuments() {(querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                        return
                        
                    } else {
                        for document in querySnapshot!.documents {
                            
                            let copyrightFlag = document.data()["copyright_flag"] as! String
                            
                            if copyrightFlag == "true" {
                                
//                                let imageRef = self.storage.child("comedian_image/\(self.comedianId).jpg")
//                                cell.comedianImageView.sd_setImage(with: imageRef, placeholderImage: UIImage(named: "noImage"))
                                
                                cell.comedianImageView.image = UIImage(named: "\(self.reviewComedianIdArray[indexPath.row])")
                                cell.comedianImageView.contentMode = .scaleAspectFill
                                cell.comedianImageView.clipsToBounds = true
                                cell.referenceButton.setTitle("", for: .normal)
                                
                            }
                            
                            if copyrightFlag == "false" {
                                
                                cell.comedianImageView.image = UIImage(named: "noImage")
                                cell.referenceButton.setTitle("", for: .normal)
                                
                            }
                            
                            if copyrightFlag == "reference" {
                                
                                let comedianReference = document.data()["reference_name"] as! String
                                cell.referenceButton.tag = indexPath.row

                                
                                //                        let imageRef = self.storage.child("comedian_image/\(self.comedianIdArray[indexPath.row]).jpg")
                                //                        cell.comedianImageView.sd_setImage(with: imageRef, placeholderImage: UIImage(named: "noImage"))
                                
                                cell.comedianImageView.image = UIImage(named: "\(self.reviewComedianIdArray[indexPath.row])")
                                //                        cell.comedianImageView.contentMode = .scaleAspectFill
                                //                        cell.comedianImageView.clipsToBounds = true
                                
                                cell.referenceButton.contentHorizontalAlignment = .left
                                cell.referenceButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 6.0)
                                cell.referenceButton.setTitle(comedianReference, for: .normal)
                                cell.referenceButton.addTarget(self, action: #selector(self.tappedReferenceButton(sender:)), for: .touchUpInside)
                                
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
                cell.likeCountButton.tag = indexPath.row
                cell.likeCountButton.addTarget(self, action: #selector(self.tappedLikeCountButton(sender:)), for: .touchUpInside)

                
                self.db.collection("like_review").whereField("review_id", isEqualTo: self.reviewIdArray[indexPath.row]).whereField("like_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
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
    
    @objc func tappedReferenceButton(sender: UIButton) {
        
        let buttonTag = sender.tag
        let tappedComedianId = self.reviewComedianIdArray[buttonTag]
        
        let button = sender
        let cell = button.superview?.superview as! NewReviewTableViewCell
        
        //copyrightflagを取得して画像をセット
        db.collection("comedian").whereField(FieldPath.documentID(), isEqualTo: tappedComedianId).getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                for document in querySnapshot!.documents {
                    
                    self.referenceUrl = document.data()["reference_url"] as! String
                    
                }
                
                let referenceVC = self.storyboard?.instantiateViewController(withIdentifier: "Reference") as! ReferenceViewController
                
                let referenceUrl = URL(string: "\(self.referenceUrl)")
                referenceVC.url = referenceUrl
                
                self.navigationController?.pushViewController(referenceVC, animated: true)
                
            }
        }
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
        let tappedComedianId = self.reviewComedianIdArray[buttonTag]
        
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

    
    //ユーザーネームタップでプロフィールページに遷移
    
//    @objc func tappedUserNameButton(sender: UIButton) {
//
//        let buttonTag = sender.tag
//        let tappedUserId = self.userIdArray[buttonTag]
//        let tappedUserName = self.userNameArray[buttonTag]
//
//
//        let button = sender
//        let cell = button.superview?.superview as! NewReviewTableViewCell
//
//
//
//        //セルタップでプロフィールに遷移
//        let profileVC = storyboard?.instantiateViewController(withIdentifier: "ProfileTab") as! ProfilePageTabViewController
//
//        profileVC.userId = tappedUserId
//        profileVC.userName = tappedUserName
//
//
//
//        self.navigationController?.pushViewController(profileVC, animated: true)
//
//
//    }
    

}
