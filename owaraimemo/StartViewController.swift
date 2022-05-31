//
//  StartViewController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/03/29.
//

import UIKit

class StartViewController: UIViewController {
    

//    @IBOutlet weak var createNewButton: UIButton!
        
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

    }
    
    
    
    
    
    
}
