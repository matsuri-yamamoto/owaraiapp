


import UIKit
import Firebase

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
        
    var searchController = UISearchController(searchResultsController: nil)
    
    //表示する芸人名の配列
    var comedianDataArray: [ComedianData] = []
    
    //SearchBarで検索されたComedianのオブジェクトを格納する配列
    var filterComedianArray: [ComedianData] = []

    //filterComedianArrayのComedianData型配列をString型に変えて格納する配列
    var searchResultArray: [String] = []
    
    
    
    //Firestoreを使うための下準備
    let currentUser = Auth.auth().currentUser
    let db = Firestore.firestore()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.delegate = self
        tableView.dataSource = self
        searchController.delegate = self
        
        // 毎回データ更新してくれるように、viewWillAppearの中に記述する
        comedianDataArray = getData()
        //ナビゲーションバーの戻るボタンを非表示
        navigationController?.navigationItem.leftBarButtonItem?.customView?.isHidden = true
        
        self.navigationItem.title = "さがす"

        // searchBarのスタイル
        searchController.searchBar.searchBarStyle = UISearchBar.Style.prominent
        
        // searchbarのサイズを調整
        searchController.searchBar.sizeToFit()
        
        // tableViewのヘッダーにsearchController.searchBarをセット
        tableView.tableHeaderView = searchController.searchBar
        
        //結果表示用のビューコントローラーに自分を設定する
        searchController.searchResultsUpdater = self
        
        // カスタムセルを登録する
        let nib = UINib(nibName: "ComedianTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        

    }
    
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
        if( searchController.searchBar.text != "" ) {
                    return searchResultArray.count
                } else {
                    return comedianDataArray.count
                }
    }

    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ComedianTableViewCell
                
        //SearchControllerに入力されている場合、SearchResultArrayの結果を返す
        if searchController.searchBar.text != "" {
            cell.textLabel?.text = ""
            cell.textLabel?.text = searchResultArray[indexPath.row]

        } else {
            //SearchControllerに入力がない場合、comedianDataArrayのデータを返す
            cell.setComedianData(comedianDataArray[indexPath.row])
        }
        return cell
    }

    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        //SearchControllerに入力されている場合、SearchResultArrayの結果を渡す
        if searchController.searchBar.text != ""  {
            
            let selectedComedianCell = filterComedianArray[indexPath.row]
            performSegue(withIdentifier: "cellSegue",sender: selectedComedianCell)
            
        } else {
            
            //SearchControllerに入力がない場合、comedianDataArrayの結果を渡す
            let selectedComedianCell = comedianDataArray[indexPath.row]
            performSegue(withIdentifier: "cellSegue",sender: selectedComedianCell)

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cellSegue" {
            let reviewVC = segue.destination as! ReviewViewController
            reviewVC.comedianData = sender as? ComedianData
        }
    }
    
    
    //検索窓押下時に呼ばれる
    func updateSearchResults(for searchController: UISearchController) {


        //検索文字列を含むデータを検索結果配列に格納する

        //フィルタした結果のcomedianDataArrayを一旦別の変数でもって、comedinadataの配列をStringの配列に変える
        filterComedianArray = comedianDataArray.filter { data in return data.comedianName.contains(searchController.searchBar.text!) }
        
        //filterComedianArrayからcomedianNameの配列を作る(map)
        //comedian：for文のところで書いてるdataみたいなもの(filterも同じ)
        searchResultArray = filterComedianArray.map({(comedian)->String in return comedian.comedianName})
        
        //テーブルを再読み込みする
        tableView.reloadData()


    }
    
}
