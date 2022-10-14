//
//  OnboardingPageViewController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/10/12.
//

import UIKit

class OnboardingPageViewController: UIPageViewController {

    //PageView上で表示するViewControllerを管理する配列
    private var controllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //初期化
        self.initPageView()
    }
    
    //初期化（PageViewで表示するViewをセット）
    func initPageView(){
        // PageViewControllerで表示するViewControllerをインスタンス化
        let firstVC = storyboard!.instantiateViewController(withIdentifier: "Onboarding") as! OnboardingViewController
        let secondVC = storyboard!.instantiateViewController(withIdentifier: "OnboardSearch") as! OnboardingSearchViewController

        // インスタンス化したViewControllerを配列に追加
        self.controllers = [ firstVC, secondVC ]

        // 最初に表示するViewControllerを指定する
        setViewControllers([self.controllers[0]],
                           direction: .forward,
                           animated: true,
                           completion: nil)

        // PageViewControllerのDataSourceとの関連付け
        self.dataSource = self
    }
}

extension OnboardingPageViewController: UIPageViewControllerDataSource {
    // スクロールするページ数
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.controllers.count
    }

    // 左にスワイプした時の処理
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = self.controllers.firstIndex(of: viewController),
            index < self.controllers.count - 1 {
            return self.controllers[index + 1]
        } else {
            return nil
        }
    }
    
    // 右にスワイプした時の処理
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = self.controllers.firstIndex(of: viewController),
            index > 0 {
            return self.controllers[index - 1]
        } else {
            return nil
        }
    }
}
