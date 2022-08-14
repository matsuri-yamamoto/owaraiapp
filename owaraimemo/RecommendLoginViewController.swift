//
//  RecommendLoginViewController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/07/11.
//

import UIKit

class RecommendLoginViewController: UIViewController {
    
    @IBOutlet weak var phraseLabel1: UILabel!
    @IBOutlet weak var phraseLabel2: UILabel!
    @IBOutlet weak var phraseLabel3: UILabel!
    
    @IBOutlet weak var mailLoginButton: UIButton!
    @IBOutlet weak var mailNewButton: UIButton!
    
    var backAnotherButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        
        let count = (self.navigationController?.viewControllers.count)! - 2
        if self.navigationController?.viewControllers[count] is MyReviewViewController {
            
            self.navigationItem.hidesBackButton = true
            backAnotherButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(backAnotherButtonTapped(_:)))
            self.navigationItem.rightBarButtonItems = [backAnotherButton]
            
        
            } else {
                
                return
                
            }
        


        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //pvログ
        AnalyticsUtil.sendScreenName(ScreenEvent(screenName: .recLoginVC))

    }
    
    
    @IBAction func clickTwitterButton(_ sender: Any) {
        //Twitterの件質問したら追記
    }
    
    @IBAction func tappedMailLogin(_ sender: Any) {
        

        let loginVC = storyboard?.instantiateViewController(withIdentifier: "Login") as! LoginViewController

        self.navigationController?.pushViewController(loginVC, animated: true)
        

    }

    @IBAction func tappedMailNew(_ sender: Any) {

        let mailNewVC = storyboard?.instantiateViewController(withIdentifier: "CreateNew") as! CreateNewViewController

        self.navigationController?.pushViewController(mailNewVC, animated: true)
        

    }
    
    @objc func backAnotherButtonTapped(_ sender: UIBarButtonItem) {
        
        let tabVC = storyboard?.instantiateViewController(withIdentifier: "Tabbar") as! TabBarController

        self.navigationController?.pushViewController(tabVC, animated: true)

        
    }
    
    
}


