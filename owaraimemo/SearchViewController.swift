


import UIKit
import Firebase

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate {
        
    var searchController = UISearchController(searchResultsController: nil)
    
    var comedianDataArray: [ComedianData] = []
    //SearchBarで検索されたComedianのオブジェクトを格納
    var searchResultArray: [ComedianData] = []
    
    //Firestoreを使うための下準備
    let currentUser = Auth.auth().currentUser
    let db = Firestore.firestore()

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchController.delegate = self
        
        self.navigationItem.title = "さがす"

        
        // searchBarのスタイル
        searchController.searchBar.searchBarStyle = UISearchBar.Style.prominent
        
        // searchbarのサイズを調整
        searchController.searchBar.sizeToFit()
        
        // tableViewのヘッダーにsearchController.searchBarをセット
        tableView.tableHeaderView = searchController.searchBar
        
        
        
        // カスタムセルを登録する
        let nib = UINib(nibName: "ComedianTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            // 毎回データ更新してくれるように、viewWillAppearの中に記述する
            comedianDataArray = getData()
            //ナビゲーションバーの戻るボタンを非表示
            navigationController?.navigationItem.leftBarButtonItem?.customView?.isHidden = true

    }
    
//    //検索窓押下時に呼ばれる
//    func searchBarTapped(searchController: UISearchController) {
//
//
//        //検索文字列を含むデータを検索結果配列に格納する
//        searchResultArray = comedianDataArray.filter { data in return data.containsString(searchController.searchBar.text!) }
//
//        //テーブルを再読み込みする
//        tableView.reloadData()
//
//
//    }
    
    
    
    func getData() -> [ComedianData] {
        let ref = db.collection("comedian")
        ref.getDocuments { (snaps, err) in
            if let err = err {
                        print("Error getting documents: \(err)")
                        return
        }
            self.comedianDataArray = snaps!.documents.map { document -> ComedianData in
            let data = ComedianData(document: document)
            return data
            }
            self.tableView.reloadData()
        }
        return comedianDataArray
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
        //comedian_idをreviewに渡す
        let selectedComedianCell = comedianDataArray[indexPath.row]
        performSegue(withIdentifier: "cellSegue",sender: selectedComedianCell)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cellSegue" {
            let reviewVC = segue.destination as! ReviewViewController
            reviewVC.comedianData = sender as? ComedianData
        }
    }
    
}
