//
//
import UIKit
import Firebase

//ナビゲーションバーのボタンの変数
var settingButtonItem: UIBarButtonItem!

class MyReviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    var comedianNameArray: [String] = []
    var comedianNameUniqueArray: [String] = []

    var comedianDataArray: [String] = []
    var comedianDataUniqueArray: [String] = []



    
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
        
        
//        //自分のレビューを取ってくる
//        db.collection("review").whereField("user_id", isEqualTo: Auth.auth().currentUser?.uid).getDocuments() { [self] (querySnapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//                return
//
//            } else {
//
//                //自分のレビューデータのcomedian_idを配列に格納する
//                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//                    comedianNameArray.append(document.data()["comedian_name"] as! String)
//                    print("comedianNameArray: \(self.comedianNameArray)")
//
//                    //値をユニークにする
//                    var set = Set<String>()
//                    let result = comedianNameArray.filter { set.insert($0).inserted }
//                    print("result: \(result)")
//
//                }
//            }
//        }
        
        db.collection("review").whereField("user_id", isEqualTo: Auth.auth().currentUser?.uid).getDocuments() { [self] (querySnapshot, err) in
            if let err = err {
                        print("Error getting documents: \(err)")
                        return
            } else {
                
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    //自分のレビューデータのcomedian_nameを配列に格納する
                    self.comedianNameArray.append(document.data()["comedian_name"] as! String)
                    print("comedianNameArray: \(self.comedianNameArray)")


                    //自分のレビューデータのcomedian_idを配列に格納する
                    self.comedianDataArray.append(document.data()["comedian_id"] as! String)
                    print("comedianDataArray: \(self.comedianDataArray)")

                    
                    //comedian_nameの値をユニークにする
                    var setName = Set<String>()
                    self.comedianNameUniqueArray = self.comedianNameArray.filter { setName.insert($0).inserted }
                    print("comedianUniqueArray: \(self.comedianNameUniqueArray)")
                    
                    //comedian_idの値をユニークにする
                    var setData = Set<String>()
                    self.comedianDataUniqueArray = self.comedianDataArray.filter { setData.insert($0).inserted }
                    print("comedianUniqueArray: \(self.comedianDataUniqueArray)")
                    
                }
                tableView.reloadData()
            }
        }
    }
                
    
//    func getData() -> [ComedianData] {
//        let ref = db.collection("comedian")
//        ref.getDocuments { (snaps, err) in
//            if let err = err {
//                        print("Error getting documents: \(err)")
//                        return
//        }
//            self.comedianDataArray = snaps!.documents.map { document -> ComedianData in
//            let data = ComedianData(document: document)
//            return data
//            }
//            self.tableView.reloadData()
//        }
//        return comedianDataArray
//    }
        
    override func viewDidAppear(_ animated: Bool) {
        //ReviewVCに渡す用のComedianDataを取得する(対象となる芸人はComedianNameArrayと同じだが、ComedianData型である必要があるため)
        //毎回データ更新してくれるように、viewDidAppearの中に記述する
        if comedianNameUniqueArray != [] {
            

        }
    }
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if comedianNameUniqueArray != [] {
            
            return comedianNameUniqueArray.count
            
        } else {
            
            return 0
            
        }
    }

    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ComedianTableViewCell
        cell.comedianNameLabel.text = comedianNameUniqueArray[indexPath.row]
        
        return cell
    }

    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let reviewVC = storyboard?.instantiateViewController(withIdentifier: "Review") as! ReviewViewController
        
        if comedianNameUniqueArray != [] {
            
            reviewVC.comedianName = comedianNameUniqueArray[indexPath.row]
            reviewVC.comedianID = comedianDataUniqueArray[indexPath.row]
            
            print("reviewVC.comedianID:\(reviewVC.comedianID)")
            
            //遷移を実行
            self.present(reviewVC, animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)

        } else {
            
            return
            
        }
    }
    
}
