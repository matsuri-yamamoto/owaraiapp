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
    
    var idArray: [String] = []
    var nameArray: [String] = []
    var userDisplayIdArray: [String] = []
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {

        self.idArray = []
        self.nameArray = []
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
                        
                        self.idArray.append(document.data()["followed_user_id"] as! String)
                        self.nameArray.append(document.data()["followed_user_name"] as! String)
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
                        
                        self.idArray.append(document.data()["following_user_id"] as! String)
                        self.nameArray.append(document.data()["following_user_name"] as! String)
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
                        
                        self.idArray.append(document.data()["like_user_id"] as! String)
                        self.nameArray.append(document.data()["like_user_name"] as! String)
                        self.userDisplayIdArray.append(document.data()["like_user_display_id"] as! String)
                        
                        
                    }
                    print("likeReviewidArray:\(self.idArray)")
                    self.tableView.reloadData()
                    
                }
            }
        }
        
        //フォロー中の芸人さんを取得
        if self.userType == "followingComedian" {
            
            //フォロー芸人数をカウント
            self.db.collection("follow_comedian").whereField("user_id", isEqualTo: currentUser?.uid).whereField("valid_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    return
                    
                } else {
                    
                    for document in querySnapshot!.documents {
                        
                        self.idArray.append(document.data()["comedian_id"] as! String)
                        self.nameArray.append(document.data()["comedian_name"] as! String)
                        
                        
                    }
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
                        
                        self.idArray.append(document.data()["followed_user_id"] as! String)
                        self.nameArray.append(document.data()["followed_user_name"] as! String)
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
                        
                        self.idArray.append(document.data()["following_user_id"] as! String)
                        self.nameArray.append(document.data()["following_user_name"] as! String)
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
                        
                        self.idArray.append(document.data()["like_user_id"] as! String)
                        self.nameArray.append(document.data()["like_user_name"] as! String)
                        self.userDisplayIdArray.append(document.data()["like_user_display_id"] as! String)
                        
                        
                    }
                    print("likeReviewidArray:\(self.idArray)")
                    self.tableView.reloadData()
                    
                }
            }
        }
        
        //フォロー中の芸人さんを取得
        if self.userType == "followingComedian" {
            
            //フォロー芸人数をカウント
            self.db.collection("follow_comedian").whereField("user_id", isEqualTo: self.profileUserId).whereField("valid_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).getDocuments() {(querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    return
                    
                } else {
                    
                    for document in querySnapshot!.documents {
                        
                        self.idArray.append(document.data()["comedian_id"] as! String)
                        self.nameArray.append(document.data()["comedian_name"] as! String)
                        
                        
                    }
                    self.tableView.reloadData()
                }
            }
        }
        
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            
        return self.idArray.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowUser", for: indexPath) as! FollowUserTableViewCell
        
        cell.userNameLabel.text = self.nameArray[indexPath.row]
        
        if self.userDisplayIdArray == [] {
            
            cell.userDisplayIdLabel.isHidden = true
            
        }
        
        if self.userDisplayIdArray != [] {
            
            cell.userDisplayIdLabel.text = "@" + self.userDisplayIdArray[indexPath.row]

        }

        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if self.userType == "followingComedian" {
            
            //セルタップでcomedianDetailに遷移
            let comedianVC = storyboard?.instantiateViewController(withIdentifier: "Comedian") as! ComedianDetailViewController
            comedianVC.comedianId = self.idArray[indexPath.row]
            self.navigationController?.pushViewController(comedianVC, animated: true)
            
            //ログ
            if self.currentUser?.uid != "Wsp1fLJUadXIZEiwvpuPWvhEjNW2"
                && self.currentUser?.uid != "AxW7CvvgzTh0djyeb7LceI1dCYF2"
                && self.currentUser?.uid != "QWQcWLgi9AV21qtZRE6cIpgfaVp2"
                && self.currentUser?.uid != "BvNA6PJte0cj2u3FISymhnrBxCf2"
                && self.currentUser?.uid != "uHOTLNXbk8QyFPIoqAapj4wQUwF2"
                && self.currentUser?.uid != "z9fKAXmScrMTolTApapJyHyCfEg2"
                && self.currentUser?.uid != "jjF5m3lbU4bU0LKBgOTf0Hzs5RI3"
                && self.currentUser?.uid != "bjOQykO7RxPO8j1SdN88Z3Q8ELM2"
                && self.currentUser?.uid != "0GA1hPehpXdE2KKcKj0tPnCiQxA3"
                && self.currentUser?.uid != "i7KQ5WLDt3Q9pw9pSdGG6tCqZoL2"
                && self.currentUser?.uid != "wWgPk67GoIP9aBXrA7SWEccwStx1" {
                
                //pvログを取得
                let logRef = Firestore.firestore().collection("logs").document()
                let logDic = [
                    "action_user_id": self.currentUser?.uid,
                    "page": "FollowingComedian",
                    "action_type": "tap_comedian",
                    "tapped_comedian_id": self.idArray[indexPath.row],
                    "tapped_user_id": "",
                    "tapped_date": "",
                    "tapped_event_id": "",
                    "create_datetime": FieldValue.serverTimestamp(),
                    "update_datetime": FieldValue.serverTimestamp(),
                    "delete_flag": false,
                    "delete_datetime": nil,
                ] as [String : Any]
                logRef.setData(logDic)
                
            }
            
            
        }
        
        if self.userType != "followingComedian" {
            
            //セルタップでプロフィールに遷移
            let profileVC = storyboard?.instantiateViewController(withIdentifier: "ProfileTab") as! ProfilePageTabViewController
            
            let userId = self.idArray[indexPath.row]
            let userName = self.nameArray[indexPath.row]
            
            profileVC.userId = userId
            profileVC.userName = userName
            
            
            self.navigationController?.pushViewController(profileVC, animated: true)

            
        }

        
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    
    
}
