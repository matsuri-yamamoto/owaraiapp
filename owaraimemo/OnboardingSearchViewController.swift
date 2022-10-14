//
//  OnboardingSearchViewController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/10/11.
//

import UIKit
import MultiAutoCompleteTextSwift
import FirebaseFirestore

class OnboardingSearchViewController: UIViewController {

    @IBOutlet weak var comedianTextField: MultiAutoCompleteTextField!
    @IBOutlet weak var errorLabel1: UILabel!
    @IBOutlet weak var errorLabel2: UILabel!
    @IBOutlet weak var errorLabel3: UILabel!
    @IBOutlet weak var reviewButton: UIButton!
    
    
    
    var comedianNameArray: [String] = []
//    var comedianIdArray: [String] = []
    var searchResultArray: [String] = []
    var comedianId :String = ""
    var comedianName :String = ""

    
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.comedianTextField.backgroundColor = UIColor.white
        self.comedianTextField.borderStyle = .none
        self.comedianTextField.layer.cornerRadius = 5
        self.comedianTextField.layer.borderColor = UIColor.lightGray.cgColor
        self.comedianTextField.layer.borderWidth  = 1
        self.comedianTextField.layer.masksToBounds = true

        self.reviewButton.layer.cornerRadius = 8
        self.reviewButton.clipsToBounds = true


    }
    

    
    
    
    @IBAction func tappedReviewButton(_ sender: Any) {
        
        Firestore.firestore().collection("comedian").whereField("comedian_name", isEqualTo: self.comedianTextField.text as Any).getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                for document in querySnapshot!.documents {
                    
                    self.comedianId = document.documentID as! String
                    self.comedianName = document.data()["for_list_name"] as! String

                    
                    if querySnapshot?.documents.count == 1 {
                        
                        self.comedianId = document.documentID as! String
                        
                        let onboardingReviewVC = self.storyboard?.instantiateViewController(withIdentifier: "OnboardReview") as! OnboardingReviewViewController
                        onboardingReviewVC.comedianId = self.comedianId
                        onboardingReviewVC.comedianName = self.comedianName

                        self.navigationController?.pushViewController(onboardingReviewVC, animated: true)
                        
                        
                    } else {
                        
                        self.errorLabel1.text = "ごめんなさい！芸人さんの表記に誤りがあるか、"
                        self.errorLabel2.text = "ツボログに未掲載の芸人さんです"
                        self.errorLabel3.text = "入力内容の見直しか、他の芸人さんの入力をお願いします"

                        
                        
                    }

                }
                
                if self.comedianId == "" {
                    
                    self.errorLabel1.text = "ごめんなさい！芸人さんの表記に誤りがあるか、"
                    self.errorLabel2.text = "ツボログに未掲載の芸人さんです"
                    self.errorLabel3.text = "入力内容の見直しか、他の芸人さんの入力をお願いします"

                }
                
                
            }
        }

        
        
    }
    
    

}
