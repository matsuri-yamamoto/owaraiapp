//
//  ReviewViewController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/03/22.
//

import UIKit
import Firebase
import FirebaseFirestore


class ReviewViewController: UIViewController,UITextViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var sliderLabel: UILabel!
    
    
    //渡されるデータを入れる変数
    var comedianName: String = ""
    var comedianID: String = ""
    var tag1: String = ""
    var tag2: String = ""
    var tag3: String = ""
    var tag4: String = ""
    var tag5: String = ""
    

    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        print("comedianID:\(comedianID)")
        
        //ナビゲーションバーにタイトルを表示させる
        self.navigationItem.title = "\(comedianName)のレビュー"
        self.navigationController?.navigationBar.titleTextAttributes = [
        // 文字の色
            .foregroundColor: UIColor.darkGray
        ]
        
        let initialValue: Float = 0
        slider.value = initialValue
        slider.tintColor = .darkGray
        slider.addTarget(self, action: #selector(sliderDidChangeValue(_:)), for: .valueChanged)
        view.addSubview(slider)
        
        
        //comedian_id=前画面から渡されたものかつuser_id=currentUser.uidのレビューがあれば参照する
        Firestore.firestore().collection("review").whereField("user_id", isEqualTo: Auth.auth().currentUser?.uid).whereField("comedian_id", isEqualTo: self.comedianID).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            } else {
                for document in querySnapshot!.documents {
                    self.slider.value = document.get("score") as! Float
                    self.textView.text = document.get("comment") as! String
                }
                let sliderDoubleValue = Double(self.slider.value)
                self.sliderLabel.text = String(sliderDoubleValue)
            }
        }
    }
    
    @objc func sliderDidChangeValue(_ sender: UISlider) {
        let roundValue = round(sender.value * 2) * 0.5
        
        // set round value
        sender.value = roundValue
        sliderLabel.text = String(roundValue)
    }
    
    
    
    @IBAction func saveButton(_ sender: Any) {
        //値の置換
        let score:Double = Double(slider.value)
        let textView:String = String(textView.text)
        
        //渡されるデータの定義
        let userId = Auth.auth().currentUser?.uid
        let deleteDateTime :String? = nil
        var documentID :String?
        
        
        //user_id=currentUserかつcomedian_idが前画面から渡されたidであるreviewドキュメントを探す
        //該当ドキュメントがあればdocumentidを取得し、なければ"doesNotExist"を入れる
        
        Firestore.firestore().collection("review").whereField("user_id", isEqualTo: Auth.auth().currentUser?.uid).whereField("comedian_id", isEqualTo: comedianID).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                
            } else {
                for document in querySnapshot!.documents {
                    documentID = document.documentID
                }
                
                
                //ドキュメントidがnilの場合、レビューを書いたことがないということなので新しくレビューを作成する
                if documentID == nil {
                    let reviewRef = Firestore.firestore().collection("review").document()
                    let reviewDic = [
                        "user_id": userId,
                        "comedian_id": self.comedianID,
                        "comedian_display_name": self.comedianName,
                        "score": score,
                        "comment": textView,
                        "tag_1": self.tag1,
                        "tag_2": self.tag2,
                        "tag_3": self.tag3,
                        "tag_4": self.tag4,
                        "tag_5": self.tag5,
                        "private_flag": false,
                        "create_datetime": FieldValue.serverTimestamp(),
                        "update_datetime": FieldValue.serverTimestamp(),
                        "delete_flag": false,
                        "delete_datetime": deleteDateTime,
                    ] as [String : Any]
                    reviewRef.setData(reviewDic)
                    self.dismiss(animated: true)
                    
                } else {
                    //nilじゃなかったら、該当ドキュメントのidを持ってくる
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        documentID = document.documentID
                        
                    //ドキュメントidがnilでない場合、レビューを書いたことがあるということなのでドキュメントを更新する
                    let existReviewRef = Firestore.firestore().collection("review").document(documentID!)
                    existReviewRef.updateData([
                        "score": score,
                        "comment": textView,
                        "update_datetime": FieldValue.serverTimestamp(),
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                            self.dismiss(animated: true)
                        }
                    }
                    }
                }
            }
        }
    }
    
    //viewをタップしたときにキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }


}
                
