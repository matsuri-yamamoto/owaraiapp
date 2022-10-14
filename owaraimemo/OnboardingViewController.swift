//
//  OnboardingViewController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/10/11.
//

import UIKit

class OnboardingViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func tappedCreateNewButton(_ sender: Any) {
        
        let onboardingSearchVC = self.storyboard?.instantiateViewController(withIdentifier: "OnboardSearch") as! OnboardingSearchViewController
        self.navigationController?.pushViewController(onboardingSearchVC, animated: true)

        
    }
    
    @IBAction func tappedLoginButton(_ sender: Any) {
        
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
