//
//
import UIKit
import Firebase

//ナビゲーションバーのボタンの変数
var settingButtonItem: UIBarButtonItem!

class MyReviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var reviewComedianArray: [ReviewData] = []
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
        
        
//        //自分のレビューを取ってくる
//        let reviewRef = db.collection("review").whereField("user_id", isEqualTo: Auth.auth().currentUser?.uid).order(by: "create_datetime", descending: true)
//        reviewRef.getDocuments { [self] (snaps, err) in
//            if let err = err {
//                        print("Error getting documents: \(err)")
//                        return
//        }
//            //自分のレビューのcomedian_idを配列で持つ
//            self.reviewComedianArray = snaps!.documents.map { document -> ReviewData in
//            let reviewData = ReviewData(document: document)
//            return reviewData
//
//            }
//        }
//
//        //各comedian_idをidに持つcomedianのnameをmapで取得する
//        let comedianRef  = self.reviewComedianArray.map { Firestore.firestore().collection("comedian").whereField("comedian_id", isEqualTo: $0) }
//
//        comedianRef.getDocument { (snap, error) in
//        }

    }


    
    
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comedianDataArray.count
    }

    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ComedianTableViewCell
        cell.setComedianData(comedianDataArray[indexPath.row])

        return cell
    }
    
    


    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "cellSegue",sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    
    }


}
