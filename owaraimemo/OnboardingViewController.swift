//
//  OnboardingViewController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/10/11.
//

import UIKit
import FirebaseFirestore

class OnboardingViewController: UIViewController {
        
    @IBOutlet weak var createNewButton: UIButton!
    @IBOutlet weak var termButton: UIButton!
    @IBOutlet weak var ppButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 15.0, *) {
            self.createNewButton.configuration = nil
            self.termButton.configuration = nil
            self.ppButton.configuration = nil
            self.loginButton.configuration = nil

        }
        self.createNewButton.setTitle("", for: .normal)
        self.termButton.setTitle("", for: .normal)
        self.ppButton.setTitle("", for: .normal)
        self.loginButton.setTitle("", for: .normal)
        
        //ログを保存する
        let onboardLogRef = Firestore.firestore().collection("onboard_log").document()
        let onboardLogDic = [
            "page": "top",
            "action": "load",
            "create_datetime": FieldValue.serverTimestamp(),
            "update_datetime": FieldValue.serverTimestamp(),
            "delete_flag": false,
            "delete_datetime": nil,
        ] as [String : Any]
        
        onboardLogRef.setData(onboardLogDic)
        

    }
    
    @IBAction func tappedCreateNewButton(_ sender: Any) {
        
        //ログを保存する
        let onboardLogRef = Firestore.firestore().collection("onboard_log").document()
        let onboardLogDic = [
            "page": "top",
            "action": "createNewTap",
            "create_datetime": FieldValue.serverTimestamp(),
            "update_datetime": FieldValue.serverTimestamp(),
            "delete_flag": false,
            "delete_datetime": nil,
        ] as [String : Any]
        
        onboardLogRef.setData(onboardLogDic)
        
        let onboardingSearchVC = self.storyboard?.instantiateViewController(withIdentifier: "OnboardSearch") as! OnboardingSearchViewController
        self.navigationController?.pushViewController(onboardingSearchVC, animated: true)

        
    }
    
    @IBAction func tappedLoginButton(_ sender: Any) {
        
        //ログを保存する
        let onboardLogRef = Firestore.firestore().collection("onboard_log").document()
        let onboardLogDic = [
            "page": "top",
            "action": "loginTap",
            "create_datetime": FieldValue.serverTimestamp(),
            "update_datetime": FieldValue.serverTimestamp(),
            "delete_flag": false,
            "delete_datetime": nil,
        ] as [String : Any]
        
        onboardLogRef.setData(onboardLogDic)
        
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! LoginViewController
        self.navigationController?.pushViewController(loginVC, animated: true)

    }
    
    @IBAction func tappedTermButton(_ sender: Any) {
        
        let termVC = self.storyboard?.instantiateViewController(withIdentifier: "Term") as! TermViewController
        self.navigationController?.pushViewController(termVC, animated: true)

        
    }
    
    @IBAction func tappedPpButton(_ sender: Any) {
        let ppVC = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyPolicy") as! PrivacyPolicyViewController
        self.navigationController?.pushViewController(ppVC, animated: true)

    }
    
    


}
