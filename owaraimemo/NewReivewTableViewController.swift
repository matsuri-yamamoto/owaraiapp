////
////  NewReivewTableViewController.swift
////  owaraimemo
////
////  Created by 山本梨野 on 2022/09/30.
////
//
//import UIKit
//import FirebaseFirestore
//import FirebaseAuth
//
//class NewReivewTableViewController: UITableViewController {
//
//    let db = Firestore.firestore()
//    let currentUser = Auth.auth().currentUser
//
//    var reviewIdArray: [String] = []
//    var comedianIdArray: [String] = []
//    var comedianNameArray: [String] = []
//    var userIdArray: [String] = []
//    var userNameArray: [String] = []
//    var userDisplayIdArray: [String] = []
//    var reviewCreateDatetimeArray: [String] = []
//    var reviewScoreArray: [String] = []
//    var reviewCommentArray: [String] = []
//    var reviewRelationalArray: [String] = []
//    var likeReviewIdArray: [String] = []
//
//    var reviewId :String = ""
//
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.title = "新着"
//
//        db.collection("review").whereField("private_flag", isEqualTo: false).whereField("delete_flag", isEqualTo: false).order(by: "create_datetime", descending: true).limit(to: 30).getDocuments() { (querySnapshot, err) in
//
//            if let err = err {
//                print("Error getting documents: \(err)")
//                return
//
//            } else {
//                for document in querySnapshot!.documents {
//
//
//                    self.reviewIdArray.append(document.documentID)
//                    self.comedianIdArray.append(document.data()["comedian_id"] as! String)
//                    self.comedianNameArray.append(document.data()["comedian_display_name"] as! String)
//                    self.userIdArray.append(document.data()["user_id"] as! String)
//                    self.userNameArray.append(document.data()["user_name"] as! String)
//
//                    self.userDisplayIdArray.append(document.data()["display_id"] as! String)
//
//                    self.reviewCreateDatetimeArray.append(document.data()["create_datetime"] as! String)
//
//                    self.reviewScoreArray.append(document.data()["score"] as! String)
//                    self.reviewCommentArray.append(document.data()["comment"] as! String)
//
//                    self.reviewRelationalArray.append(document.data()["relational_comedian_listname"] as! String)
//
//
//                }
//
//            }
//        }
//    }
//
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        self.reviewId = self.reviewIdArray[indexPath.row]
//
//
//
//        //likereviewをセット
//        db.collection("like_review").whereField("review_id", isEqualTo: reviewId).whereField("like_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//                return
//
//            } else {
//                //like_reviewドキュメントが0件の場合
//                if querySnapshot!.documents.count == 0 {
//                    cell.likeCountLabel.text = "いいね！はまだありません"
//                } else {
//                    cell.likeCountLabel.text = "\(querySnapshot!.documents.count)件のいいね！"
//
//                    //自分のlike_frag==trueのレビュー有無でレビューボタンの色を変える
//                    self.db.collection("like_review").whereField("review_id", isEqualTo: self.reviewId).whereField("like_user_id", isEqualTo: self.currentUser?.uid as Any).whereField("like_flag", isEqualTo: true).getDocuments() { [self](querySnapshot, err) in
//
//                        if let err = err {
//                            print("Error getting documents: \(err)")
//                            return
//
//                        } else {
//
//                            if querySnapshot!.documents.count == 0 {
//
//                                cell.likeButton.setImage(self.unLikeImage, for: .normal)
//
//                            } else {
//
//                                cell.likeButton.setImage(self.likeImage, for: .normal)
//
//                            }
//
//
//                        }
//                    }
//
//                }
//            }
//        }
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        <#code#>
//    }
//
//
//}
