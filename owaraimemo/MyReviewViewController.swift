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
    var nonReviewFlag = false
    var comedianDataArray: [ComedianData] = []
    
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
 
            } else {
                
                //自分のレビューデータのcomedian_idを配列に格納する
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    comedianArray.append(document.data()["comedian_id"] as! String)
                    print("comedianArray: \(self.comedianArray)")
                    
                }
                
                if comedianArray.isEmpty {
                    comedianNameArray = []
                    
                } else {
                
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
                            self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getData() -> [ComedianData] {
        db.collection("comedian").whereField(FieldPath.documentID(), in: comedianArray).getDocuments() { (querySnapshot, err) in
            if let err = err {
                        print("Error getting documents: \(err)")
                        return
        }
            self.comedianDataArray = querySnapshot!.documents.map { document -> ComedianData in
            let data = ComedianData(document: document)
            return data
            }
            self.tableView.reloadData()
        }
        return comedianDataArray
    }
        
    
    override func viewDidAppear(_ animated: Bool) {
        //ReviewVCに渡す用のComedianDataを取得する(対象となる芸人はComedianNameArrayと同じだが、ComedianData型である必要があるため)
        //毎回データ更新してくれるように、viewWillAppearの中に記述する
        if comedianNameArray != [] {
                    
            comedianDataArray = getData()
            print("comedianDataArray:\(comedianDataArray)")
            
        }
    }
    
    
    
                                
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if comedianNameArray != [] {
            
            print("comedianDataArray.count:\(comedianDataArray.count)")
            return comedianDataArray.count
            
        } else {
            
            return 0
            
        }
    }

    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ComedianTableViewCell
        cell.textLabel?.text = comedianNameArray[indexPath.row]
        return cell
    }
    



    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if comedianNameArray != [] {
                        
            let selectedComedianCell = comedianDataArray[indexPath.row]
            performSegue(withIdentifier: "cellSegue",sender: selectedComedianCell)
            tableView.deselectRow(at: indexPath, animated: true)

        } else {
            
            return
            
        }

    }
    
}
