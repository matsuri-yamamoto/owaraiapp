//
//  ReviewViewController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/03/22.
//

import UIKit
import Firebase


class ReviewViewController: UIViewController,UITextViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var sliderLabel: UILabel!
    
    @IBAction func sliderValue(_ sender: Any) {
            sliderLabel.text = String(slider.value)
            
    }
        
    var comedianData: ComedianData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.text = comedianData.comedianName
        
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
                
        //保存場所の定義
        let reviewRef = Firestore.firestore().collection("review").document()
        
        //値の置換
        let score:Double = Double(slider.value)
        let textView:String = String(textView.text)
        
        //渡されるデータの定義
        let userId = Auth.auth().currentUser?.uid
        let comedianId = comedianData.id
        let deleteDateTime :String? = nil
        
        //Firestoreにデータを保存
        let reviewDic = [
            "user_id": userId,
            "comedian_id": comedianId,
            "score": score,
            "comment": textView,
            "private_flag": false,
            "create_datetime": FieldValue.serverTimestamp(),
            "update_datetime": FieldValue.serverTimestamp(),
            "delete_flag": false,
            "delete_datetime": deleteDateTime,
        ] as [String : Any]
        reviewRef.setData(reviewDic)
        
        self.textView.endEditing(true)
        
        self.dismiss(animated: true)
        
        
    }
    
    //viewをタップしたときにキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //改行ボタン(return、決定ボタン)が押された際に呼ばれる
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
    
    

    
    

}
