//
//  OnboardingReviewViewController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/10/11.
//

import UIKit
import Firebase
import FirebaseFirestore
import MultiAutoCompleteTextSwift

class OnboardingReviewViewController: UIViewController ,UITextViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var textView: PlaceTextView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var sliderLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    var displayId: String!    
    var comedianId :String = ""
    
    //comedianTextFieldに予測表示させる芸人の配列
    var comedianNameArray: [String] = []
    
    //渡されるデータを入れる変数
    var comedianName: String = ""
    var comedianID: String = ""
    var tag1: String = ""
    var tag2: String = ""
    var tag3: String = ""
    var tag4: String = ""
    var tag5: String = ""
    
    // インジゲーターの設定
    var indicator = UIActivityIndicatorView()

    
    
    let currentUser = Auth.auth().currentUser


    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        print("comedianName:\(comedianName)")
        
        print("comedianID:\(comedianID)")
        
        //ナビゲーションバーにタイトルを表示させる
        self.navigationItem.title = "\(comedianName)の感想"
        self.navigationController?.navigationBar.titleTextAttributes = [
            // 文字の色
            .foregroundColor: UIColor.darkGray
        ]
        
        let initialValue: Float = 0
        slider.value = initialValue
        slider.tintColor = UIColor.systemYellow
        slider.addTarget(self, action: #selector(sliderDidChangeValue(_:)), for: .valueChanged)
        view.addSubview(slider)
        
        
        //comedian_id=前画面から渡されたものかつuser_id=currentUser.uidのレビューがあれば参照する
        Firestore.firestore().collection("review").whereField("user_id", isEqualTo: currentUser?.uid).whereField("comedian_id", isEqualTo: self.comedianID).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            } else {
                
                //レビューがなければプレースホルダーを設定する
                if querySnapshot?.documents.count == 0 {
                    self.textView.placeHolder = "ネタバレ、過度な批判・誹謗中傷の" + "\n" + "公開保存は禁止です！" + "\n" + "ツボった度のみでも保存できます"
                    
                } else {
                    for document in querySnapshot!.documents {
                        self.slider.value = document.get("score") as! Float
                        self.textView.text = document.get("comment") as? String
                        let sliderDoubleValue = Double(self.slider.value)
                        self.sliderLabel.text = String(format: "%.1f", sliderDoubleValue)

                    }
                }
            }
        }
        
        // 表示位置を設定（画面中央）
        self.indicator.center = view.center
        // インジケーターのスタイルを指定（白色＆大きいサイズ）
        self.indicator.style = .large
        // インジケーターの色を設定（青色）
        self.indicator.color = UIColor.darkGray
        // インジケーターを View に追加
        view.addSubview(indicator)
        
        //ログを保存する
        let onboardLogRef = Firestore.firestore().collection("onboard_log").document()
        let onboardLogDic = [
            "page": "review",
            "action": "load",
            "create_datetime": FieldValue.serverTimestamp(),
            "update_datetime": FieldValue.serverTimestamp(),
            "delete_flag": false,
            "delete_datetime": nil,
        ] as [String : Any]
        
        onboardLogRef.setData(onboardLogDic)


        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //pvログ
        AnalyticsUtil.sendScreenName(ScreenEvent(screenName: .reviewVC))
    }
    
    @objc func sliderDidChangeValue(_ sender: UISlider) {
        let roundValue = round(sender.value*10)/10
        
        // set round value
        sender.value = roundValue
        sliderLabel.text = String(roundValue)
    }
    
    
    //text の変更後に UITextView を一番下までスクロールする
    func addText(_ text: String) {
        textView.isScrollEnabled = false
        textView.text = textView.text + text
        scrollToBottom()
    }
    
    func scrollToBottom() {
        textView.selectedRange = NSRange(location: textView.text.count, length: 0)
        textView.isScrollEnabled = true
        
        let scrollY = textView.contentSize.height - textView.bounds.height
        let scrollPoint = CGPoint(x: 0, y: scrollY > 0 ? scrollY : 0)
        textView.setContentOffset(scrollPoint, animated: true)
    }
    
    @IBAction func tappedSaveButton(_ sender: Any) {
        
        
        
        if (self.sliderLabel.text == "0" || self.sliderLabel.text == "0.0") {
            
            //アラート生成
            //UIAlertControllerのスタイルがalert
            let alert: UIAlertController = UIAlertController(title: "ツボった度が0点です", message:  "入力漏れの場合はキャンセルしツボった度を入力してください", preferredStyle:  UIAlertController.Style.alert)
            
            // 確定ボタンの処理
            let confirmAction: UIAlertAction = UIAlertAction(title: "保存", style: UIAlertAction.Style.default, handler:{
                // 確定ボタンが押された時の処理をクロージャ実装する
                (action: UIAlertAction!) -> Void in
                
                //値の置換
                let score :Double = Double(self.slider.value)
                let comment :String = String(self.textView.text)
                
                
                let onboardingCreateNewVC = self.storyboard?.instantiateViewController(withIdentifier: "OnboardCreateNew") as! OnboardingCreateNewViewController
                onboardingCreateNewVC.comedianId = self.comedianId
                onboardingCreateNewVC.comedianName = self.comedianName
                onboardingCreateNewVC.score = score
                onboardingCreateNewVC.comment = comment



                self.navigationController?.pushViewController(onboardingCreateNewVC, animated: true)


                
                
            })
            
            // キャンセルボタンの処理
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                // キャンセルボタンが押された時の処理をクロージャ実装する
                (action: UIAlertAction!) -> Void in
                //実際の処理
                print("キャンセル")
                return

            })
            
            //UIAlertControllerにキャンセルボタンと確定ボタンをActionを追加
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
            
            //実際にAlertを表示する
            present(alert, animated: true, completion: nil)
                                                             
            
        } else {
            
            self.indicator.startAnimating()

            
            //値の置換
            let score :Double = Double(self.slider.value)
            let comment :String = String(self.textView.text)
            
            
            let onboardingCreateNewVC = self.storyboard?.instantiateViewController(withIdentifier: "OnboardCreateNew") as! OnboardingCreateNewViewController
            onboardingCreateNewVC.comedianId = self.comedianId
            onboardingCreateNewVC.comedianName = self.comedianName
            onboardingCreateNewVC.score = score
            onboardingCreateNewVC.comment = comment



            self.navigationController?.pushViewController(onboardingCreateNewVC, animated: true)
            
            self.indicator.stopAnimating()

        

        }
        
        //ログを保存する
        let onboardLogRef = Firestore.firestore().collection("onboard_log").document()
        let onboardLogDic = [
            "page": "review",
            "action": "saveTap",
            "create_datetime": FieldValue.serverTimestamp(),
            "update_datetime": FieldValue.serverTimestamp(),
            "delete_flag": false,
            "delete_datetime": nil,
        ] as [String : Any]
        
        onboardLogRef.setData(onboardLogDic)

    }
    
    //viewをタップしたときにキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    
    
}
