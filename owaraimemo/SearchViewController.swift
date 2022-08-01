


import UIKit
import Firebase
import FirebaseFirestore

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
        
    var searchController = UISearchController(searchResultsController: nil)
    
    //表示する芸人名の配列
    var comedianDataArray: [String] = []
    var comedianNameArray: [String] = []
    
    //SearchBarで検索されたComedianのオブジェクトを格納する配列
    var filterComedianArray: [String] = []

    //filterComedianArrayのComedianData型配列をString型に変えて格納する配列
    var searchResultNameArray: [String] = []
    var searchResultData: String = ""
    
    var comedianId: String = ""
    
    
    
    //Firestoreを使うための下準備
    let currentUser = Auth.auth().currentUser
    let db = Firestore.firestore()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchController.delegate = self
        
        //ナビゲーションバーの戻るボタンを非表示
        navigationController?.navigationItem.leftBarButtonItem?.customView?.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        
        self.navigationItem.title = "さがす"

        // searchBarのスタイル
        searchController.searchBar.searchBarStyle = UISearchBar.Style.prominent
        
        // searchbarのサイズを調整
        searchController.searchBar.sizeToFit()
        
        // tableViewのヘッダーにsearchController.searchBarをセット
        tableView.tableHeaderView = searchController.searchBar
        
        //結果表示用のビューコントローラーに自分を設定する
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "芸人さんの名前で検索"
        
        //SearchControllerを使用する際に画面遷移時に発生する問題を解消する
        definesPresentationContext = true
        
        // カスタムセルを登録する
        let nib = UINib(nibName: "ComedianTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        
        db.collection("comedian").getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                for document in querySnapshot!.documents {
                    self.comedianDataArray.append(document.documentID)
                    self.comedianNameArray.append(document.data()["for_list_name"] as! String)
                }
                self.tableView.reloadData()
            }
            }
    }

    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if( searchController.searchBar.text != "" ) {
                    return searchResultNameArray.count
                } else {
//                    return comedianNameArray.count
                    return 0
                }
    }

    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ComedianTableViewCell
        //SearchControllerに入力されている場合、SearchResultArrayの結果を返す
        if searchController.searchBar.text != "" {
            cell.comedianNameLabel.text = searchResultNameArray[indexPath.row]
            return cell

        } else {
            //SearchControllerに入力がない場合、comedianNameArrayのデータを返す
//            cell.comedianNameLabel.text = comedianNameArray[indexPath.row]
            cell.comedianNameLabel.text = ""
        }
        return cell
    }

    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
        let comedianVC = storyboard?.instantiateViewController(withIdentifier: "Comedian") as! ComedianDetailViewController

        //SearchControllerに入力されている場合、SearchResultArrayの結果を渡す
        if searchController.searchBar.text != ""  {

            //芸人名からcomedian_idを特定する
            db.collection("comedian").whereField("for_list_name", isEqualTo: searchResultNameArray[indexPath.row]).getDocuments() {
                (querySnapshot, err) in
                    if let err = err {
                                print("Error getting documents: \(err)")
                                return

                    } else {
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            
                            
                            
                            self.searchResultData = document.documentID
                            
                            
                            print("searchResultData:\(self.searchResultData)")
                            
                        }
                        //comedian_idをセットする
                        self.comedianId = self.searchResultData
                        print("comedianId:\(self.comedianId)")
                        
                        //comedianIdを渡して画面遷移
                        comedianVC.comedianId = self.comedianId
                        self.navigationController?.pushViewController(comedianVC, animated: true)
                        tableView.deselectRow(at: indexPath, animated: true)
                    }
            }
        }
    }
        
    //検索窓押下時に呼ばれる
    func updateSearchResults(for searchController: UISearchController) {

        
        //検索文字列を含むデータを検索結果配列に格納する。
        searchResultNameArray = comedianNameArray.filter { data in
            return data.contains(searchController.searchBar.text!)
        }
        
        //テーブルを再読み込みする
        tableView.reloadData()


    }
    
}
