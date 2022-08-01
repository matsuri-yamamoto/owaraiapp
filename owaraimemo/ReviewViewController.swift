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
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var sliderLabel: UILabel!
    @IBOutlet weak var comedianTextField: MultiAutoCompleteTextField!
    
    @IBOutlet weak var tweetButton: UIButton!
    
    
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
        
        print("comedianID:\(comedianID)")
        
        //ナビゲーションバーにタイトルを表示させる
        self.navigationItem.title = "\(comedianName)のレビュー"
        self.navigationController?.navigationBar.titleTextAttributes = [
        // 文字の色
            .foregroundColor: UIColor.darkGray
        ]
        
        
        //Twitterボタンの画像をセットする
        tweetButton.setImage(UIImage(named: "tweet_false"), for: .normal)
        
        
        let initialValue: Float = 0
        slider.value = initialValue
        slider.tintColor = .darkGray
        slider.addTarget(self, action: #selector(sliderDidChangeValue(_:)), for: .valueChanged)
        view.addSubview(slider)
        
        
        //comedian_id=前画面から渡されたものかつuser_id=currentUser.uidのレビューがあれば参照する
        Firestore.firestore().collection("review").whereField("user_id", isEqualTo: currentUser?.uid).whereField("comedian_id", isEqualTo: self.comedianID).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            } else {
                for document in querySnapshot!.documents {
                    self.slider.value = document.get("score") as! Float
                    self.textView.text = document.get("comment") as? String
                }
                let sliderDoubleValue = Double(self.slider.value)
                self.sliderLabel.text = String(sliderDoubleValue)
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
        
    }
    
    @objc func sliderDidChangeValue(_ sender: UISlider) {
        let roundValue = round(sender.value * 2) * 0.5
        
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
    
    
    @IBAction func saveButton(_ sender: Any) {
        //値の置換
        let score:Double = Double(slider.value)
        let textView:String = String(textView.text)
        
        //渡されるデータの定義
        let userId = Auth.auth().currentUser?.uid
        let displayId = Auth.auth().currentUser?.displayName
    
        let deleteDateTime :String? = nil
        var documentID :String?
        var userName :String?
        
        //ニックネームの取得
        Firestore.firestore().collection("user_detail").whereField("user_id", isEqualTo: currentUser?.uid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                
            } else {
                for document in querySnapshot!.documents {
                    userName = document.data()["username"] as? String
                    
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
        } else {
            
            return
        }
        
        
        
    }
    
    //Twitterシェアボタンをタップしたときの処理
    @IBAction func tweetButtonTapped(_ sender: Any) {
        
        //シェアフラグの切り替えとボタンの画像の切り替え
        if twitterShareFlag == false {
            twitterShareFlag = true
            tweetButton.setImage(UIImage(named: "tweet_true"), for: .normal)
        }
        
        if twitterShareFlag == true {
            twitterShareFlag = false
            tweetButton.setImage(UIImage(named: "tweet_false"), for: .normal)
            
        }
    }
    
    
    func shareOnTwitter() {

        let text = textView.text

        //芸人名のハッシュタグを作成
        let comedianName = comedianName
        let hashTag = "#ハッシュタグ"
        let comedianNameHashTag = comedianName + "\n" + hashTag
        
        //ツボログのハッシュタグを作成
        let tsubologHashTag = "ツボログ" + "\n" + hashTag
        
        //レビュー内容の定数を作成
        let reviewContents = textView.text
        
        //作成したテキストをエンコード
        let encodedHashtag = comedianNameHashTag.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        //エンコードしたテキストをURLに繋げ、URLを開いてツイート画面を表示させる
        if let encodedHashtag = encodedHashtag,
            let url = URL(string: "https://twitter.com/intent/tweet?text=\(encodedHashtag)") {
            UIApplication.shared.open(url)
        }
    }
    
//    //Twitterシェア用のURL生成
//    func makeShareUrl() {
//
//        var components = URLComponents()
//        components.scheme = "https"
//        //作成したドメイン
//        components.host = "tsubolog.page.link"
//        //任意のパス
//        components.path = "/share"
//
////        //アプリに戻ってきた時に受け取る値を保存
////        let queryItem = URLQueryItem(name: "share", value: "Hello")
////        components.queryItems = [queryItem]
//
//        //リンクの作成
//        guard let link = components.url else {return}
//        let dynamicLinksDomainURIPrefix = "https://tsubolog.page.link"
//        guard let shareLink = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix) else {return}
//
//        if let bundleID = Bundle.main.bundleIdentifier {
//            shareLink.iOSParameters = DynamicLinkIOSParameters(bundleID: bundleID)
//        }
//        // 未インストール時にストアへ遷移するためにAppStoreID
//        shareLink.iOSParameters?.appStoreID = "Your AppStoreID"
//        shareLink.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
//
//        shareLink.socialMetaTagParameters?.title = "Hello World"
//        shareLink.socialMetaTagParameters?.descriptionText = "テストです"
//        shareLink.socialMetaTagParameters?.imageURL = URL(string: "https://storage.googleapis.com/zenn-user-upload/topics/0b0064a451.jpeg")
//
//
//        //ショートリンクの作成
//        shareLink.shorten { url, warnings, err in
//            if err != nil {
//                return
//            }else{
//                if let warnings = warnings {
//                    for warning in warnings {
//                        print("\(warning)")
//                    }
//                }
//                guard let url = url else {return}
//                let activityItems: [Any] = [url,ShareActivitySource(url: url, title: "Hello World", image: self.logoImageView.image!)]
//                let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: .none)
//                self.present(activityViewController, animated: true, completion: nil)
//            }
//        }
//
//
//    }
    
    
    
    
    //viewをタップしたときにキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }


}
                
