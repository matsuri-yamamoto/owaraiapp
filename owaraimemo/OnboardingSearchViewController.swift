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

    // インジゲーターの設定
    var indicator = UIActivityIndicatorView()

    
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.comedianTextField.backgroundColor = UIColor.white
        self.comedianTextField.borderStyle = .none
        self.comedianTextField.layer.cornerRadius = 5
        self.comedianTextField.layer.borderColor = UIColor.lightGray.cgColor
        self.comedianTextField.layer.borderWidth  = 1
        self.comedianTextField.layer.masksToBounds = true
        
        
        // 表示位置を設定（画面中央）
        self.indicator.center = view.center
        // インジケーターのスタイルを指定（白色＆大きいサイズ）
        self.indicator.style = .large
        // インジケーターの色を設定（青色）
        self.indicator.color = UIColor.darkGray
        // インジケーターを View に追加
        view.addSubview(indicator)
        
        if #available(iOS 15.0, *) {
            self.reviewButton.configuration = nil
        }
        self.reviewButton.setTitle("", for: .normal)
        
        //ログを保存する
        let onboardLogRef = Firestore.firestore().collection("onboard_log").document()
        let onboardLogDic = [
            "page": "search",
            "action": "load",
            "create_datetime": FieldValue.serverTimestamp(),
            "update_datetime": FieldValue.serverTimestamp(),
            "delete_flag": false,
            "delete_datetime": nil,
        ] as [String : Any]
        
        onboardLogRef.setData(onboardLogDic)

    }
    

    
    
    
    @IBAction func tappedReviewButton(_ sender: Any) {
        
        //ログを保存する
        let onboardLogRef = Firestore.firestore().collection("onboard_log").document()
        let onboardLogDic = [
            "page": "search",
            "action": "reviewTap",
            "create_datetime": FieldValue.serverTimestamp(),
            "update_datetime": FieldValue.serverTimestamp(),
            "delete_flag": false,
            "delete_datetime": nil,
        ] as [String : Any]
        
        onboardLogRef.setData(onboardLogDic)
        
        self.indicator.startAnimating()
        
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
                        
                        self.indicator.stopAnimating()
                        
                        
                    } else {
                        
                        self.errorLabel1.text = "ごめんなさい！芸人さんの表記に誤りがあるか、"
                        self.errorLabel2.text = "ツボログに未掲載の芸人さんです"
                        self.errorLabel3.text = "入力内容の見直しか、他の芸人さんの入力をお願いします"

                        self.indicator.stopAnimating()

                        
                    }

                }
                
                if self.comedianId == "" {
                    
                    self.errorLabel1.text = "ごめんなさい！芸人さんの表記に誤りがあるか、"
                    self.errorLabel2.text = "ツボログに未掲載の芸人さんです"
                    self.errorLabel3.text = "入力内容の見直しか、他の芸人さんの入力をお願いします"
                    
                    self.indicator.stopAnimating()

                }
                
                
            }
        }

        
        
    }
    
    

}
