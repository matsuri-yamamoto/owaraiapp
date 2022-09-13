//
//  UserNameViewController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/08/17.
//

import UIKit
import Firebase
import FirebaseFirestore

class UserNameViewController: UIViewController {
    
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func tappedSaveButton(_ sender: Any) {
        
        //過去にログインしたことがなかったら、user_detailを作成する
        Firestore.firestore().collection("user_detail").whereField("user_id", isEqualTo: Auth.auth().currentUser?.uid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                
            } else {
                                    
                    let deleteDateTime :String? = nil

                    let userNameRef = Firestore.firestore().collection("user_detail").document()
                    let userNameDic = [
                        "user_id": Auth.auth().currentUser?.uid,
                        "username": self.userNameTextField.text,
                        "create_datetime": FieldValue.serverTimestamp(),
                        "update_datetime": FieldValue.serverTimestamp(),
                        "delete_flag": false,
                        "delete_datetime": deleteDateTime,
                    ] as [String : Any]
                    
                    print("userNameDic\(userNameDic)")
                    userNameRef.setData(userNameDic)
                    


                    let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "Tabbar") as! TabBarController
                    self.navigationController?.pushViewController(tabBarVC, animated: true)
            }
        }
    }
}
    
                            
