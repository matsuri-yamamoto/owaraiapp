//
//  ReviewViewController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/03/22.
//

import UIKit
import Firebase
import FirebaseFirestore
import MultiAutoCompleteTextSwift



class ReviewViewController: UIViewController,UITextViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var textView: PlaceTextView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var sliderLabel: UILabel!
    @IBOutlet weak var comedianTextField: MultiAutoCompleteTextField!
    
    @IBOutlet weak var tweetButton: UIButton!
    @IBOutlet weak var twitterImageView: UIImageView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    var displayId: String!
    
    
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
    
    var twitterShareFlag: Bool = false
    
    let currentUser = Auth.auth().currentUser
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        print("comedianName:\(comedianName)")
        
        print("comedianID:\(comedianID)")
        
        //ナビゲーションバーにタイトルを表示させる
        self.navigationItem.title = "\(comedianName)の感想"
        self.navigationController?.navigationBar.titleTextAttributes = [
            // 文字の色
            .foregroundColor: UIColor.darkGray
        ]
        
        
        //Twitterボタンの画像をセットする
        tweetButton.setImage(UIImage(named: "tweet_false"), for: .normal)
        
        
        let initialValue: Float = 0
        slider.value = initialValue
        slider.tintColor = #colorLiteral(red: 1, green: 0.8525225841, blue: 0.1762744927, alpha: 1)
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
                    self.textView.placeHolder = "ネタバレ、過度な批判・誹謗中傷の" + "\n" + "公開保存は禁止です！" + "\n" + "芸人さんやファンの方に" + "\n" + "直接言える言葉で書きましょう"
                    
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
        
        //comedianTextFieldに候補を表示させる
        Firestore.firestore().collection("comedian").getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                for document in querySnapshot!.documents {
                    self.comedianNameArray.append(document.data()["for_list_name"] as! String)
                }
                self.comedianTextField.autoCompleteStrings = self.comedianNameArray
            }
        }
        
        
        
        self.twitterImageView.image = UIImage(named: "twitterShare_false")
        self.view.addSubview(self.twitterImageView)
        self.tweetButton.backgroundColor = #colorLiteral(red: 0.9333333373, green: 0.9333333373, blue: 0.9333333373, alpha: 1)
        self.tweetButton.setTitleColor(#colorLiteral(red: 0.424124063, green: 0.424124063, blue: 0.424124063, alpha: 1), for: .normal)
        self.tweetButton.setTitle("      TwitterシェアOFF", for: .normal)
        //左右・上下中央寄せ
        self.tweetButton.titleLabel?.textAlignment = NSTextAlignment.center
        self.tweetButton.titleLabel?.baselineAdjustment = .alignCenters
        
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
        //値の置換
        let score:Double = Double(slider.value)
        let textView:String = String(textView.text)
        
        //渡されるデータの定義
        let userId = Auth.auth().currentUser?.uid
        let userName = Auth.auth().currentUser?.displayName
        
        let deleteDateTime :String? = nil
        var documentID :String?
        var displayId :String?
        
        //ニックネームの取得
        Firestore.firestore().collection("user_detail").whereField("user_id", isEqualTo: currentUser?.uid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                
            } else {
                print("件数:\(querySnapshot?.documents.count)")
                
                for document in querySnapshot!.documents {
                    displayId = document.get("display_id") as? String
                    print("displayId:\(displayId)")

                    //user_id=currentUserかつcomedian_idが前画面から渡されたidであるreviewドキュメントを探す
                    //該当ドキュメントがあればdocumentidを取得し、なければ"doesNotExist"を入れる
                    
                    Firestore.firestore().collection("review").whereField("user_id", isEqualTo: self.currentUser?.uid).whereField("comedian_id", isEqualTo: self.comedianID).getDocuments() { (querySnapshot, err) in
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
                                    "user_id": userId!,
                                    "display_id": displayId!,
                                    "user_name": userName!,
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
                                    "relational_comedian_listname": self.comedianTextField.text!,
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
                                        "display_id": displayId!,
                                        "user_name": userName!,
                                        "score": score,
                                        "comment": textView,
                                        "private_flag": false,
                                        "relational_comedian_listname": self.comedianTextField.text!,
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
            }
            
        }
        
        //TwitterフラグがtrueならばTwitterを起動
        if twitterShareFlag == true {
            shareOnTwitter()
            
            //ログ
            AnalyticsUtil.sendAction(ActionEvent(screenName: .reviewVC,
                                                         actionType: .tap,
                                                 actionLabel: .template(ActionLabelTemplate.reviewSaveButtonTap_shareTwitter)))

        }
        
        if twitterShareFlag == false {
            
            //ログ
            AnalyticsUtil.sendAction(ActionEvent(screenName: .reviewVC,
                                                         actionType: .tap,
                                                 actionLabel: .template(ActionLabelTemplate.reviewSaveButtonTap_noTwitter)))
            
            return
        }
    }
    
    @IBAction func tappedPrivateSaveButton(_ sender: Any) {
        
        
        //値の置換
        let score:Double = Double(slider.value)
        let textView:String = String(textView.text)
        
        //渡されるデータの定義
        let userId = Auth.auth().currentUser?.uid
        let userName = Auth.auth().currentUser?.displayName
        
        let deleteDateTime :String? = nil
        var documentID :String?
        var displayId :String?
        
        //ニックネームの取得
        Firestore.firestore().collection("user_detail").whereField("user_id", isEqualTo: currentUser?.uid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                
            } else {
                for document in querySnapshot!.documents {
                    displayId = document.data()["display_id"] as? String
                    print("displayId:\(displayId)")
                    
                    //user_id=currentUserかつcomedian_idが前画面から渡されたidであるreviewドキュメントを探す
                    //該当ドキュメントがあればdocumentidを取得し、なければ"doesNotExist"を入れる
                    
                    Firestore.firestore().collection("review").whereField("user_id", isEqualTo: self.currentUser?.uid).whereField("comedian_id", isEqualTo: self.comedianID).getDocuments() { (querySnapshot, err) in
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
                                    "user_id": userId!,
                                    "display_id": displayId! as String,
                                    "user_name": userName!,
                                    "comedian_id": self.comedianID,
                                    "comedian_display_name": self.comedianName,
                                    "score": score,
                                    "comment": textView,
                                    "tag_1": self.tag1,
                                    "tag_2": self.tag2,
                                    "tag_3": self.tag3,
                                    "tag_4": self.tag4,
                                    "tag_5": self.tag5,
                                    "private_flag": true,
                                    "relational_comedian_listname": self.comedianTextField.text!,
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
                                        "display_id": displayId!,
                                        "user_name": userName!,
                                        "score": score,
                                        "comment": textView,
                                        "private_flag": true,
                                        "relational_comedian_listname": self.comedianTextField.text!,
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
            }
        }
        
        //ログ
        AnalyticsUtil.sendAction(ActionEvent(screenName: .reviewVC,
                                                     actionType: .tap,
                                             actionLabel: .template(ActionLabelTemplate.reviewPrivateSaveButtonTap)))
        
    }
    
    
    
    
    
    //Twitterシェアボタンをタップしたときの処理
    @IBAction func tweetButtonTapped(_ sender: Any) {
        
        
        switch twitterShareFlag {
        case false:
            twitterShareFlag = true
            self.twitterImageView.image = UIImage(named: "twitter")
            self.view.addSubview(self.twitterImageView)
            self.tweetButton.backgroundColor = #colorLiteral(red: 0.1884371638, green: 0.6279121637, blue: 0.9447771311, alpha: 1)
            self.tweetButton.setTitleColor(.white, for: .normal)
            self.tweetButton.setTitle("      TwitterシェアON", for: .normal)
            //左右・上下中央寄せ
            self.tweetButton.titleLabel?.textAlignment = NSTextAlignment.center
            self.tweetButton.titleLabel?.baselineAdjustment = .alignCenters
            
            
        case true:
            twitterShareFlag = false
            self.twitterImageView.image = UIImage(named: "twitterShare_false")
            self.view.addSubview(self.twitterImageView)
            self.tweetButton.backgroundColor = #colorLiteral(red: 0.9333333373, green: 0.9333333373, blue: 0.9333333373, alpha: 1)
            self.tweetButton.setTitleColor(#colorLiteral(red: 0.424124063, green: 0.424124063, blue: 0.424124063, alpha: 1), for: .normal)
            self.tweetButton.setTitle("      TwitterシェアOFF", for: .normal)
            //左右・上下中央寄せ
            self.tweetButton.titleLabel?.textAlignment = NSTextAlignment.center
            self.tweetButton.titleLabel?.baselineAdjustment = .alignCenters
            
        }
                
        print("twitterShareFlag:\(twitterShareFlag)")
    }
    
    
    func shareOnTwitter() {
        
        var comedianName :String!
        
        
        Firestore.firestore().collection("comedian").whereField(FieldPath.documentID(), in: [self.comedianID]).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                
            } else {
                print("querySnapshot?.documents.count:\(querySnapshot?.documents.count)")
                for document in querySnapshot!.documents {
                    comedianName = document.data()["comedian_name"] as? String
                    print("comedianName:\(comedianName as String)")
                    
                    
                    let url = "https://urlzs.com/1MmQo"
                    
                    let hashTag = "#"

                    //芸人名のハッシュタグを作成
                    let comedianNameHashTag = hashTag + comedianName
                    
                    //ツボログのハッシュタグを作成
                    let tsubologHashTag = hashTag + "ツボログ"
                    
                    //レビュー内容、URL、ハッシュタグを結合
                    let reviewContents = self.textView.text!
                    print("reviewContents:\(reviewContents)")
                    let reviewHashTag = reviewContents + "\n" + comedianNameHashTag + "\n" + tsubologHashTag + "\n" + url
                    
                    print("reviewHashTag:\(reviewHashTag)")
                    
                    
                    //作成したテキストをエンコード
                    let encodedHashtag = reviewHashTag.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    
                    //エンコードしたテキストをURLに繋げ、URLを開いてツイート画面を表示させる
                    if let encodedHashtag = encodedHashtag,
                       let url = URL(string: "https://twitter.com/intent/tweet?text=\(encodedHashtag)") {
                        UIApplication.shared.open(url)
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

