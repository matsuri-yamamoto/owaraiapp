


import UIKit
import WebKit

class WKWebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    var webView: WKWebView!
    var urlString: String!
    var url: URL!

    var browserButtonItem: UIBarButtonItem!

    
    override func loadView() {

        // 2 WKWebViewConfiguration の生成
        let webConfiguration = WKWebViewConfiguration()
        // 3 WKWebView に Configuration を引き渡し initialize
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        // 4 WKUIDelegate の移譲先として self を登録
        webView.uiDelegate = self
        // 5 WKNavigationDelegate の移譲先として self を登録
        webView.navigationDelegate = self
        // 6 view に webView を割り当て
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myRequest = URLRequest(url: url!)
        webView.load(myRequest)
        
        
        //ナビゲーションバーのボタン設置
        self.browserButtonItem = UIBarButtonItem(image: UIImage(systemName: "network"), style: .done, target: self, action: #selector(browserButtonPressed))
        self.navigationItem.rightBarButtonItem = browserButtonItem
        
        
//        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        
    }
    
    @objc func browserButtonPressed() {
        
        UIApplication.shared.open(self.url!)


    }
}

