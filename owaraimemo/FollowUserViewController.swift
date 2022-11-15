//
//  FollowViewController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/10/07.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth


class FollowUserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let db = Firestore.firestore()
    let currentUser = Auth.auth().currentUser
    
    var userType :String = ""
    
    var reviewId :String = ""
    
    var profileUserId :String = ""
        
    var userIdArray: [String] = []
    var userNameArray: [String] = []
    var userDisplayIdArray: [String] = []


    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.userIdArray = []
        self.userNameArray = []
        self.userDisplayIdArray = []
        
        print("userType:\(self.userType)")
        print("reviewId:\(self.reviewId)")

        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let nib = UINib(nibName: "FollowUserTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "FollowUser")
        
        
        if self.profileUserId == "" {
            
            self.setUserList()
            
            
        } else {
            
            self.setProfileUserList()
            
            
            
        }
    }
        
    
    func setUserList() {
        
        //自分がフォロー中のユーザーを取得
        if self.userType == "following" {
            
            db.collection("follow").whereField("following_user_id", isEqualTo: currentUser?.uid).whereField("valid_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).order(by: "update_datetime", descending: true).getDocuments() { (querySnapshot, err) in
                
                if let err = err {
                    print("Error getting documents: \(err)")
                    return
                    
                } else {
                    for document in querySnapshot!.documents {
                        
                        self.userIdArray.append(document.data()["followed_user_id"] as! String)
                        self.userNameArray.append(document.data()["followed_user_name"] as! String)
                        self.userDisplayIdArray.append(document.data()["followed_user_display_id"] as! String)

                    }
                    self.tableView.reloadData()
                }
            }
        }
        
        //自分をフォローしているユーザーを取得
        if self.userType == "followed" {
            
            db.collection("follow").whereField("followed_user_id", isEqualTo: currentUser?.uid).whereField("valid_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).order(by: "update_datetime", descending: true).getDocuments() { (querySnapshot, err) in
                
                if let err = err {
                    print("Error getting documents: \(err)")
                    return
                    
                } else {
                    for document in querySnapshot!.documents {
                        
                        self.userIdArray.append(document.data()["following_user_id"] as! String)
                        self.userNameArray.append(document.data()["following_user_name"] as! String)
                        self.userDisplayIdArray.append(document.data()["following_user_display_id"] as! String)

                    }
                    self.tableView.reloadData()

                }
            }
        }
        
        //レビューをいいねしているユーザーを取得
        if self.userType == "likeReview" {
            
            db.collection("like_review").whereField("review_id", isEqualTo: self.reviewId).whereField("like_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).order(by: "update_datetime", descending: true).getDocuments() { (querySnapshot, err) in
                
                if let err = err {
                    print("Error getting documents: \(err)")
                    return
                    
                } else {
                    for document in querySnapshot!.documents {
                        
                        self.userIdArray.append(document.data()["like_user_id"] as! String)
                        self.userNameArray.append(document.data()["like_user_name"] as! String)
                        self.userDisplayIdArray.append(document.data()["like_user_display_id"] as! String)
                        

                    }
                    print("likeReviewUserIdarray:\(self.userIdArray)")
                    self.tableView.reloadData()

                }
            }
        }
        

    }
    
    func setProfileUserList() {
        
        //自分がフォロー中のユーザーを取得
        if self.userType == "following" {
            
            db.collection("follow").whereField("following_user_id", isEqualTo: self.profileUserId).whereField("valid_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).order(by: "update_datetime", descending: true).getDocuments() { (querySnapshot, err) in
                
                if let err = err {
                    print("Error getting documents: \(err)")
                    return
                    
                } else {
                    for document in querySnapshot!.documents {
                        
                        self.userIdArray.append(document.data()["followed_user_id"] as! String)
                        self.userNameArray.append(document.data()["followed_user_name"] as! String)
                        self.userDisplayIdArray.append(document.data()["followed_user_display_id"] as! String)

                    }
                    self.tableView.reloadData()
                }
            }
        }
        
        //自分をフォローしているユーザーを取得
        if self.userType == "followed" {
            
            db.collection("follow").whereField("followed_user_id", isEqualTo: self.profileUserId).whereField("valid_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).order(by: "update_datetime", descending: true).getDocuments() { (querySnapshot, err) in
                
                if let err = err {
                    print("Error getting documents: \(err)")
                    return
                    
                } else {
                    for document in querySnapshot!.documents {
                        
                        self.userIdArray.append(document.data()["following_user_id"] as! String)
                        self.userNameArray.append(document.data()["following_user_name"] as! String)
                        self.userDisplayIdArray.append(document.data()["following_user_display_id"] as! String)

                    }
                    self.tableView.reloadData()

                }
            }
        }
        
        //レビューをいいねしているユーザーを取得
        if self.userType == "likeReview" {
            
            db.collection("like_review").whereField("review_id", isEqualTo: self.reviewId).whereField("like_flag", isEqualTo: true).order(by: "update_datetime", descending: true).whereField("delete_flag", isEqualTo: false).getDocuments() { (querySnapshot, err) in
                
                if let err = err {
                    print("Error getting documents: \(err)")
                    return
                    
                } else {
                    for document in querySnapshot!.documents {
                        
                        self.userIdArray.append(document.data()["like_user_id"] as! String)
                        self.userNameArray.append(document.data()["like_user_name"] as! String)
                        self.userDisplayIdArray.append(document.data()["like_user_display_id"] as! String)
                        

                    }
                    print("likeReviewUserIdarray:\(self.userIdArray)")
                    self.tableView.reloadData()

                }
            }
        }
        

    }

    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("self.likereviewUserIdArray.count:\(self.userIdArray.count)")
        return self.userIdArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowUser", for: indexPath) as! FollowUserTableViewCell
        
        cell.userNameLabel.text = self.userNameArray[indexPath.row]
        cell.userDisplayIdLabel.text = "@" + self.userDisplayIdArray[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //セルタップでプロフィールに遷移
        let profileVC = storyboard?.instantiateViewController(withIdentifier: "ProfileTab") as! ProfilePageTabViewController

        let userId = self.userIdArray[indexPath.row]
        let userName = self.userNameArray[indexPath.row]

        profileVC.userId = userId
        profileVC.userName = userName

        
        
        self.navigationController?.pushViewController(profileVC, animated: true)

        self.tableView.deselectRow(at: indexPath, animated: true)

    }
    


    
}
