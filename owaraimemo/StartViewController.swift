//
//  StartViewController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/03/29.
//

import UIKit

class StartViewController: UIViewController, SearchDelegate {
    

    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createNewButton: UIButton!
    
    var loginViewController: LoginVIewController!
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        loginViewController?.searchDelegate = self
                
    }
    
    
    func searchDelegate() {
        performSegue(withIdentifier: "searchSegue", sender: nil)
        
    }
    
}
