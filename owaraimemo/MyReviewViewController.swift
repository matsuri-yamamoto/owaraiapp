//
//
import UIKit
import Firebase

//ナビゲーションバーのボタンの変数
var settingButtonItem: UIBarButtonItem!

class MyReviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var comedianArray: [String] = []
    var comedianNameArray: [String] = []
    var reviewComedianArray: [Any] = []
    var comedianDataArray: [ComedianData] = []
    var nonReviewFlag = false
    
    //Firestoreを使うための下準備
    let currentUser = Auth.auth().currentUser
    let db = Firestore.firestore()

    
    @IBOutlet weak var tableView: UITableView!
    
    @objc func settingButtonPressed() {
        
        performSegue(withIdentifier: "settingSegue", sender: nil)
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        
        tableView.delegate = self
        tableView.dataSource = self

        title = "マイページ"
        
        //ナビゲーションバーのボタン設置
        settingButtonItem = UIBarButtonItem(title: "設定", style: .done, target: self, action: #selector(settingButtonPressed))
        self.navigationItem.rightBarButtonItem = settingButtonItem
        
        navigationController?.navigationItem.leftBarButtonItem?.customView?.isHidden = true
        
        self.tabBarController?.tabBar.isHidden = false
        
        // カスタムセルを登録す
        let nib = UINib(nibName: "ComedianTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        
        //自分のレビューを取ってくる
        db.collection("review").whereField("user_id", isEqualTo: Auth.auth().currentUser?.uid).getDocuments() { [self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
 
            } else if querySnapshot == nil {

                return

            } else {
                
                //自分のレビューデータのcomedian_idを配列に格納する
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    comedianArray.append(document.data()["comedian_id"] as! String)
                    print("comedianArray: \(self.comedianArray)")
                }
                
                self.db.collection("comedian").whereField(FieldPath.documentID(), in: comedianArray).getDocuments() { (querySnapshot, err) in

                    if let err = err {
                        print("Error getting documents: \(err)")
                        return
                        
                    } else {
                        //自分のレビューデータのcomedian_idを配列に格納する
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            comedianNameArray.append(document.data()["comedian_name"] as! String)
                            print("comedianNameArray: \(comedianNameArray)")
                            }
                        }
                    }
            }
        }
    }
                                
    
        // データの数（＝セルの数）を返すメソッド
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if nonReviewFlag == true {
            return 0
            } else {
                return comedianArray.count
            }
        }
    
        // 各セルの内容を返すメソッド
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            // 再利用可能な cell を得る
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ComedianTableViewCell

            if nonReviewFlag == true {
                cell.isHidden = true
                return cell
            } else {
                cell.textLabel?.text = comedianNameArray[indexPath.row]
                return cell
            }
        }
}
    
        
    
    
//    // 各セルを選択した時に実行されるメソッド
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        performSegue(withIdentifier: "cellSegue",sender: nil)
//        tableView.deselectRow(at: indexPath, animated: true)
//
//    }
