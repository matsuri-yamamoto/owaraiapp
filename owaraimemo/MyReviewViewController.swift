//
//
import UIKit

//ナビゲーションバーのボタンの変数
var settingButtonItem: UIBarButtonItem!

class MyReviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    
    @objc func settingButtonPressed() {
        
        //settingViewControllerを取得
        let settingViewController = self.storyboard?.instantiateViewController(withIdentifier: "Setting") as! SettingViewController
        let navigationController = UINavigationController(rootViewController: settingViewController)
        self.navigationController?.modalPresentationStyle = .overCurrentContext
        navigationController.setNavigationBarHidden(false, animated: true)
        self.navigationController?.present(navigationController, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        title = "マイページ"
        
        //ナビゲーションバーのボタン設置
        settingButtonItem = UIBarButtonItem(title: "設定", style: .done, target: self, action: #selector(settingButtonPressed))
        self.navigationItem.rightBarButtonItem = settingButtonItem

    }
    
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        return cell
    }

    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "cellSegue",sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    
    }


}
