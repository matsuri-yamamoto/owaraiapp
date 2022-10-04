//
//  MyPageTabViewController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/10/04.
//

import UIKit
import Tabman
import Pageboy

class MyPageTabViewController: TabmanViewController {

    private var viewControllers = [UIViewController(), UIViewController(), UIViewController(), UIViewController()]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        
        self.navigationItem.hidesBackButton = true
        self.title = "マイページ"
        
        
        
        
        
        // Create bar
        let bar = TMBar.ButtonBar()
        bar.layout.transitionStyle = .snap // Customize
        bar.backgroundView.style = .flat(color: .white)
        
        bar.layout.contentInset = UIEdgeInsets(top: 50.0, left: 10.0, bottom: 0.0, right: 10.0)
        
        bar.layout.contentMode = .fit

        bar.buttons.customize { (button) in
            button.tintColor = #colorLiteral(red: 0.2851759885, green: 0.2851759885, blue: 0.2851759885, alpha: 1)
            button.selectedTintColor = #colorLiteral(red: 0.1738873206, green: 0.1738873206, blue: 0.1738873206, alpha: 1)
            button.font = UIFont.systemFont(ofSize: 13)
            button.selectedFont = UIFont.boldSystemFont(ofSize: 13)
        }
        bar.indicator.backgroundColor = #colorLiteral(red: 0.2851759885, green: 0.2851759885, blue: 0.2851759885, alpha: 1)
        bar.indicator.weight = .custom(value: 3)

        // Add to view
        addBar(bar, dataSource: self, at: .top)
        
        //ナビゲーションバーのボタン設置
        settingButtonItem = UIBarButtonItem(image: UIImage(systemName: "text.justify"), style: .done, target: self, action: #selector(settingButtonPressed))
        self.navigationItem.rightBarButtonItem = settingButtonItem
        
        navigationController?.navigationItem.leftBarButtonItem?.customView?.isHidden = true
        
        self.tabBarController?.tabBar.isHidden = false
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        

        
    }
        
    private func setTabsControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let firstVC = storyboard.instantiateViewController(withIdentifier: "MyReview") as! MyReviewViewController
        let secondVC = storyboard.instantiateViewController(withIdentifier: "Stock") as! StockViewController
        let thirdVC = storyboard.instantiateViewController(withIdentifier: "Following") as! FollowingViewController
        let forthVC = storyboard.instantiateViewController(withIdentifier: "LikeList") as! LikeListViewController
        
        viewControllers[0] = firstVC
        viewControllers[1] = secondVC
        viewControllers[2] = thirdVC
        viewControllers[3] = forthVC

    }
    
    @objc func settingButtonPressed() {
        
        performSegue(withIdentifier: "settingSegue", sender: nil)
        
    }
}



extension MyPageTabViewController: PageboyViewControllerDataSource, TMBarDataSource {

    //タブの数を決める
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        
        setTabsControllers()
        return viewControllers.count
    }
    
    //タブに該当するviewcontrollerを決める
    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }
    
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
    

    //タブバーの要件を決める
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        let title = ["レビュー", "あとでみる", "フォロー中", "いいね"]
        return TMBarItem(title: title[index])
        
        
        
    }
}
