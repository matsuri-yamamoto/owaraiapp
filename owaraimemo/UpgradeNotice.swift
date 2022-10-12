//
//  UpgradeNotice.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/10/11.
//

import UIKit

class UpgradeNotice {
    internal static let shared = UpgradeNotice()
    private init() {}
    private let apple_id = "1626953189"
    internal func fire() {
        guard let url = URL(string: "https://itunes.apple.com/jp/lookup?id=\(apple_id)") else {
            return
        }
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60)
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            guard let data = data else {
                return
            }
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                let storeVersion = ((jsonData?["results"] as? [Any])?.first as? [String : Any])?["version"] as? String                
                let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
                
                print("storeVersion:\(storeVersion!)")
                print("appVersion:\(appVersion!)")

                switch storeVersion?.compare(appVersion!, options: .numeric) {
                case .orderedDescending:
                    DispatchQueue.main.async {
                        self.showAlert()
                    }
                    return
                case .orderedSame, .orderedAscending:
                    return
                case .none:
                    return
                    
                }
                
            }catch {
            }
        })
        task.resume()
    }
    
    private func showAlert() {
            guard let parent = topViewController() else {
                return
            }
            let actionA = UIAlertAction(title: "更新", style: .default, handler: {
                        (action: UIAlertAction!) in
                
                let url = URL(string: "https://apps.apple.com/app/id\(self.apple_id)")
                UIApplication.shared.open(url!)
//                if let url = "https://urlzs.com/1MmQo",
//                    UIApplication.shared.canOpenURL(url) {
//                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                }
            })
            
            let actionB = UIAlertAction(title: "あとで", style: .default, handler: {
                        (action: UIAlertAction!) in
            })
            
            let alert: UIAlertController = UIAlertController(title: "最新バージョンのお知らせ", message: "最新バージョンがあります！かなり変わっていますので、ぜひ更新お願いいたします", preferredStyle: .alert)
            alert.addAction(actionA)
            alert.addAction(actionB)
            parent.present(alert, animated: true, completion: nil)
        }
        
        private func topViewController() -> UIViewController? {
            
            //keywindow取得の処理をios16以上と以下で分ける
            if #available(iOS 16.0, *) {
                
                var vc = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first?.windows.filter { $0.isKeyWindow }.first?.rootViewController
                while vc?.presentedViewController != nil {
                    vc = vc?.presentedViewController
                }
                return vc

                
            } else {
                
                var vc = UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController
                while vc?.presentedViewController != nil {
                    vc = vc?.presentedViewController
                }
                return vc
                
            }
            
        }
    
}
