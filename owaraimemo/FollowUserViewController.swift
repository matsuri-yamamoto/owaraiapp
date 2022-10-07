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
        
    var userIdArray: [String] = []
    var userNameArray: [String] = []
    var userDisplayIdArray: [String] = []


    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let nib = UINib(nibName: "FollowUserTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "FollowUser")
        
        self.setUserList()
        
    }
    
    
    func setUserList() {
        
        //自分がフォロー中のユーザーを取得
        if self.userType == "following" {
            
            db.collection("follow").whereField("following_user_id", isEqualTo: currentUser?.uid).whereField("valid_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).getDocuments() { (querySnapshot, err) in
                
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
            
            db.collection("follow").whereField("followed_user_id", isEqualTo: currentUser?.uid).whereField("valid_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).getDocuments() { (querySnapshot, err) in
                
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

    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.userIdArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowUser", for: indexPath) as! FollowUserTableViewCell
        
        cell.userNameLabel.text = self.userNameArray[indexPath.row]
        cell.userDisplayIdLabel.text = self.userDisplayIdArray[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //セルタップでレビュー全文に遷移
        let profileVC = storyboard?.instantiateViewController(withIdentifier: "ProfileTab") as! ProfilePageTabViewController
        
        let userId = self.userIdArray[indexPath.row]
        profileVC.userId = userId
        self.navigationController?.pushViewController(profileVC, animated: true)
        hidesBottomBarWhenPushed = true
        
        self.tableView.deselectRow(at: indexPath, animated: true)

    }
    


    
}
