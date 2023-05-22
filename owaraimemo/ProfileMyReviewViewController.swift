//
//  ProfileMyReviewViewController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/10/08.
//

import UIKit
import Firebase
import FirebaseFirestore

//ナビゲーションバーのボタンの変数

class ProfileMyReviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var profileUserId :String = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    var comedianNameArray: [String] = []
    var comedianIdArray: [String] = []
    var reviewIdArray: [String] = []
    var updatedArray: [String] = []
    var scoreArray: [Double] = []
    var commentArray: [String] = []
    
    
    var referenceUrl :String = ""

    var reviewId :String = ""
        
    //Firestoreを使うための下準備
    let db = Firestore.firestore()
    
    //いいねボタン用の画像
    let likeImage = UIImage(systemName: "heart.fill")
    let unLikeImage = UIImage(systemName: "heart")
    
    //画像のパス
//    let storage = Storage.storage(url:"gs://owaraiapp-f80fd.appspot.com").reference()
    
    
    
    @objc func settingButtonPressed() {
        
        performSegue(withIdentifier: "settingSegue", sender: nil)
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        
        print("profileUserId:\(profileUserId)")
        
                
            
        //あとでみるに切り替えた状態から別タブに移動して戻ってきたときに、レビューを再度セットする処理
        self.comedianNameArray = []
        self.comedianIdArray = []
        self.reviewIdArray = []
        self.updatedArray = []
        self.scoreArray = []
        self.commentArray = []
        self.tableView.reloadData()

        
        db.collection("review").whereField("user_id", isEqualTo: self.profileUserId).order(by: "update_datetime", descending: true).whereField("private_flag", isEqualTo: false).getDocuments() { [self] (querySnapshot, err) in
            if let err = err {
                        print("Error getting documents: \(err)")
                        return
            } else {
        
                for document in querySnapshot!.documents {
                    
                    //自分のレビューデータの各fieldを配列に格納する
                    
                    self.reviewIdArray.append(document.documentID as! String)
                    self.comedianNameArray.append(document.data()["comedian_display_name"] as! String)
                    self.comedianIdArray.append(document.data()["comedian_id"] as! String)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .short
                    dateFormatter.timeStyle = .short
                    dateFormatter.locale = Locale(identifier: "ja_JP")
                    dateFormatter.dateFormat = "yyyy/MM/dd hh:mm"
                    let updated = document.data()["update_datetime"] as! Timestamp
                    let updatedDate = updated.dateValue()
                    let updatedDateTime = dateFormatter.string(from: updatedDate)
                    self.updatedArray.append(updatedDateTime)
                    
                    self.scoreArray.append(document.data()["score"] as! Double)

                    self.commentArray.append(document.data()["comment"] as! String)
//                        self.myReviewRelationalArray.append(document.data()["relational_comedian_listname"] as! String)
                    
                                        
                }
                
                print("profileReviewId:\(self.reviewIdArray)")
                self.tableView.reloadData()
            }
        }

        
        
    
        self.tableView.delegate = self
        self.tableView.dataSource = self

        
        
                                
        

        //セルを指定
        
        let nib = UINib(nibName: "MyReviewTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "MyReviewCell")
        

                    
    
    }
                
        
    override func viewDidAppear(_ animated: Bool) {
        //ReviewVCに渡す用のComedianDataを取得する(対象となる芸人はcomedianNameArrayと同じだが、ComedianData型である必要があるため)
        //毎回データ更新してくれるように、viewDidAppearの中に記述する
        if comedianNameArray != [] {
            

        }
    
        //pvログ
        AnalyticsUtil.sendScreenName(ScreenEvent(screenName: .myReviewVC))
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                    
        return self.reviewIdArray.count
            
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        self.reviewId = self.reviewIdArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyReviewCell", for: indexPath) as! MyReviewTableViewCell
        
        cell.comedianNameButton.tag = indexPath.row
        cell.comedianNameButton.addTarget(self, action: #selector(tappedcomedianButton(sender:)), for: .touchUpInside)

        
        cell.comedianNameButton.contentHorizontalAlignment = .left
        cell.comedianNameButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        cell.comedianNameButton.setTitle(self.comedianNameArray[indexPath.row], for: .normal)
        cell.updatedLabel.text = "最終更新 - " + self.updatedArray[indexPath.row]
        
        
        
        let scoreText = String(format: "%.1f", self.scoreArray[indexPath.row])
        cell.scoreLabel.text = scoreText
        cell.scoreImageView.image = UIImage(named: "score_\(scoreText)")

        cell.commentLabel.text = self.commentArray[indexPath.row]
        cell.commentLabel.attributedText = cell.commentLabel.text?.attributedString(lineSpace: 5)
        cell.commentLabel.font = cell.commentLabel.font.withSize(13)
        cell.commentLabel.tintColor = UIColor.darkGray
        cell.commentLabel.textAlignment = NSTextAlignment.left
        

        
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
                        cell.comedianImageView.contentMode = .scaleAspectFill
                        cell.comedianImageView.clipsToBounds = true
                        
                        cell.referenceButton.setTitle("", for: .normal)

                        
                    }
                    
                    if copyrightFlag == "false" {
                        
                        cell.comedianImageView.image = UIImage(named: "noImage")
                        cell.referenceButton.setTitle("", for: .normal)
                        
                    }
                    
                    if copyrightFlag == "reference" {
                        

                        let comedianImage: UIImage? = UIImage(named: "\(self.comedianIdArray[indexPath.row])")
                        //画像がAssetsにあれば画像と引用元を表示し、なければ引用元なしのnoImageをセット
                        if let validImage = comedianImage {

                            let comedianReference = document.data()["reference_name"] as! String
                            cell.referenceButton.tag = indexPath.row
                            self.referenceUrl = document.data()["reference_url"] as! String

                            cell.referenceButton.contentHorizontalAlignment = .left
                            cell.referenceButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 6.0)
                            cell.referenceButton.setTitle(comedianReference, for: .normal)
                            cell.referenceButton.addTarget(self, action: #selector(self.tappedReferenceButton(sender:)), for: .touchUpInside)
                            
                            cell.comedianImageView.image = comedianImage
                            cell.comedianImageView.contentMode = .scaleAspectFill
                            cell.comedianImageView.clipsToBounds = true


                        } else {
                            
                            //画像がない場合
                            
                            cell.comedianImageView.image = UIImage(named: "noImage")
                            cell.referenceButton.setTitle("", for: .normal)

                            
                        }
                        
                    }
                }
            }
        }
        

        //likereviewをセット
        
        cell.likeCountButton.addTarget(self, action: #selector(tappedLikeCountButton(sender:)), for: .touchUpInside)

        
        db.collection("like_review").whereField("review_id", isEqualTo: self.reviewId).whereField("like_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                
                cell.likeCountButton.contentHorizontalAlignment = .left
                cell.likeCountButton.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
                cell.likeCountButton.setTitle("\(querySnapshot!.documents.count)", for: .normal)
                
            }
        }

        return cell

    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 350
    
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        //セルタップでレビュー全文に遷移
        let allReviewVC = storyboard?.instantiateViewController(withIdentifier: "AllReview") as! AllReviewViewController
        
        allReviewVC.reviewId = self.reviewIdArray[indexPath.row]
        self.navigationController?.pushViewController(allReviewVC, animated: true)
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        

    }
    
    //芸人名タップでcomedianDetailに遷移
    @objc func tappedcomedianButton(sender: UIButton) {
        
        
        let buttonTag = sender.tag
        let tappedComedianId = self.comedianIdArray[buttonTag]
        
        let button = sender
        let cell = button.superview?.superview as! MyReviewTableViewCell
        
        //セルタップでレビュー全文に遷移
        let comedianVC = storyboard?.instantiateViewController(withIdentifier: "Comedian") as! ComedianDetailViewController
        
        comedianVC.comedianId = tappedComedianId
        self.navigationController?.pushViewController(comedianVC, animated: true)
        
        
    }
    
    @objc func tappedReferenceButton(sender: UIButton) {
        
        let buttonTag = sender.tag
        let tappedComedianId = self.comedianIdArray[buttonTag]
        
        
        //copyrightflagを取得して画像をセット
        db.collection("comedian").whereField(FieldPath.documentID(), isEqualTo: tappedComedianId).getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                for document in querySnapshot!.documents {
                    
                    self.referenceUrl = document.data()["reference_url"] as! String
                    
                }
                
                let referenceUrl = URL(string: "\(self.referenceUrl)")
                UIApplication.shared.open(referenceUrl!)

            }
        }
    }

    
    
    @objc func tappedContinuationButton(sender: UIButton) {
        
        
        let buttonTag = sender.tag
        let tappedReviewId = self.reviewIdArray[buttonTag]
        
        let button = sender
        let cell = button.superview?.superview as! MyReviewTableViewCell
        
        //セルタップでレビュー全文に遷移
        let AllReviewVC = storyboard?.instantiateViewController(withIdentifier: "AllReview") as! AllReviewViewController
        
        AllReviewVC.reviewId = tappedReviewId
        self.navigationController?.pushViewController(AllReviewVC, animated: true)
        
        
    }
    
    //いいね欄タップでfollowVCに遷移
    @objc func tappedLikeCountButton(sender: UIButton) {
        
        
        let buttonTag = sender.tag
        let tappedReviewId = self.reviewIdArray[buttonTag]
        
        let button = sender
        let cell = button.superview?.superview as! MyReviewTableViewCell
        
        //セルタップでレビュー全文に遷移
        let followVC = storyboard?.instantiateViewController(withIdentifier: "FollowUser") as! FollowUserViewController
        
        followVC.reviewId = tappedReviewId
        followVC.userType = "likeReview"
        self.navigationController?.pushViewController(followVC, animated: true)
        
        
    }

    
}
