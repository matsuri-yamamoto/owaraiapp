
import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // タブアイコンの色
        self.tabBar.tintColor = #colorLiteral(red: 0.356847465, green: 0.3796798885, blue: 0.4218770862, alpha: 1)
        // タブバーの背景色
        self.tabBar.barTintColor = #colorLiteral(red: 0.9151250124, green: 0.9152784944, blue: 0.9151048064, alpha: 1)
        // UITabBarControllerDelegateプロトコルのメソッドをこのクラスで処理する。
        self.delegate = self
    }

    // タブバーのアイコンがタップされた時に呼ばれるdelegateメソッドを処理する。
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

            return true
    
        }

}
