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
        let sliderValue:Double = Double(slider.value)
        sliderLabel.text = String(sliderValue)
    }
        
    var comedianData: ComedianData!
    var reviewData: ReviewData!

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        label.text = comedianData.comedianName
        
        //comedian_id=前画面から渡されたものかつuser_id=currentUser.uidのレビューがあれば参照する
        Firestore.firestore().collection("review").whereField("user_id", isEqualTo: Auth.auth().currentUser?.uid).whereField("comedian_id", isEqualTo: comedianData.id).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
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
    
    
    @IBAction func saveButton(_ sender: Any) {
        //値の置換
        let score:Double = Double(slider.value)
        let textView:String = String(textView.text)
        
        //渡されるデータの定義
        let userId = Auth.auth().currentUser?.uid
        let comedianId = comedianData.id
        let deleteDateTime :String? = nil
        var documentID :String?
        
        //user_id=currentUserかつcomedian_idが前画面から渡されたidであるreviewドキュメントを探す
        //該当ドキュメントがあればdocumentidを取得し、なければ"doesNotExist"を入れる
        
        Firestore.firestore().collection("review").whereField("user_id", isEqualTo: Auth.auth().currentUser?.uid).whereField("comedian_id", isEqualTo: comedianData.id).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            } else {
                //①エラーじゃなかったら、該当ドキュメントのidを持ってくる
                for document in querySnapshot!.documents {
                    documentID = document.get("id") as? String
                    
                    //※ここで問題点発覚
                    print("document：\(documentID)")
                    
                    //②ドキュメントidがnilの場合、レビューを書いたことがないということなので新しくレビューを作成する
                    if documentID == nil {
                        let reviewRef = Firestore.firestore().collection("review").document()
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
                        self.dismiss(animated: true)
        
                    } else {
                        //③ドキュメントidがnilでない場合、レビューを書いたことがあるということなのでドキュメントを更新する
                        let existReviewRef = Firestore.firestore().collection("review").document(documentID!)
                        existReviewRef.updateData([
                            "score": score,
                            "comment": textView,
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
                
                
                
//            } else if documentID != nil {
//                for document in querySnapshot!.documents {
//                    documentID = document.documentID
//                    print("get successfully!")
//                    print("document\(documentID)")
//                }
//            } else if documentID == nil {
//                    documentID = "doesNotExist"
//                }
//            print(documentID)
//            //該当するreviewドキュメントが存在しない場合、レコードを新規作成する
//            if documentID == "doesNotExist" {
//                let reviewRef = Firestore.firestore().collection("review").document()
//                let reviewDic = [
//                    "user_id": userId,
//                    "comedian_id": comedianId,
//                    "score": score,
//                    "comment": textView,
//                    "private_flag": false,
//                    "create_datetime": FieldValue.serverTimestamp(),
//                    "update_datetime": FieldValue.serverTimestamp(),
//                    "delete_flag": false,
//                    "delete_datetime": deleteDateTime,
//                ] as [String : Any]
//                reviewRef.setData(reviewDic)
//                self.dismiss(animated: true)
//
//                //該当するドキュメントが存在する場合、そのドキュメントのスコアとコメントをアップデートする
//            } else {
//                let existReviewRef = Firestore.firestore().collection("review").document(documentID!)
//                existReviewRef.updateData([
//                    "score": score,
//                    "comment": textView,
//                ]) { err in
//                    if let err = err {
//                        print("Error updating document: \(err)")
//                    } else {
//                        print("Document successfully updated")
//                        self.dismiss(animated: true)
//                    }
//                }
//            }
//
//
//            }
//
//
//    }
        
       
        
    

    

    
    

    
    

