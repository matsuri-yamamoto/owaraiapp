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
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true

        // Do any additional setup after loading the view.
    }
    
    @IBAction func clickTwitterButton(_ sender: Any) {
        //Twitterの件質問したら追記
    }
    
    
    
    
    

}
