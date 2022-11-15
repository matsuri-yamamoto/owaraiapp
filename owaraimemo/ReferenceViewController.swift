

import UIKit
// 1 WebKit の import
import WebKit

class ReferenceViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    var webView: WKWebView!
    
    var url: URL!
    
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

        // 7 URLオブジェクトを生成
//        let url = URL(string:"\(String(describing: self.urlString))")
        
        print("url:\(url)")
        // 8 URLRequestオブジェクトを生成
        let myRequest = URLRequest(url: url!)

        // 9 URLを WebView にロード
        webView.load(myRequest)
    }
}