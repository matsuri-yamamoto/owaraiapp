//
//  ViewController.swift
//  tabTestApp
//
//  Created by 山本梨野 on 2022/06/20.
//

import UIKit
import Tabman
import Pageboy

class TabViewController: TabmanViewController {

    private var viewControllers = [UIViewController(), UIViewController(), UIViewController(), UIViewController()]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        
        let firstVC = storyboard?.instantiateViewController(withIdentifier: "FirstTab") as! FirstTabViewController
        let secondVC = storyboard?.instantiateViewController(withIdentifier: "SecondTab") as! SecondTabViewController
        let thirdVC = storyboard?.instantiateViewController(withIdentifier: "ThirdTab") as! ThirdTabViewController
        let forthVC = storyboard?.instantiateViewController(withIdentifier: "ForthTab") as! ForthTabViewController

        
        viewControllers[0] = firstVC
        viewControllers[1] = secondVC
        viewControllers[2] = thirdVC
        viewControllers[3] = forthVC

        // Create bar
        let bar = TMBar.ButtonBar()
        bar.layout.transitionStyle = .snap // Customize
        
        bar.layout.contentInset = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)

        // Add to view
        addBar(bar, dataSource: self, at: .top)
    }
}



extension TabViewController: PageboyViewControllerDataSource, TMBarDataSource {

    //タブの数を決める
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
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
        let title = [" トレンド ", "M-1トップ3", " KOC2回戦 ", "注目の若手"]
        return TMBarItem(title: title[index])
    }
}
