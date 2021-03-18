
import UIKit
import WebKit
import CashCore

class WebViewController: UIViewController, WKUIDelegate {
    
    var client: CashCore!
    @IBOutlet var webView: WKWebView!
    private var urlComponents: URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "cash-dev.coinsquareatm.com"
        urlComponents.path = "external"
        return urlComponents
    }
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.uiDelegate = self
        
        var components = self.urlComponents
        components.setQueryItems(with: ["mode" : "kyc",
                                        "key": client.sessionKey])
        let myRequest = URLRequest(url: URL(string: "https://cash-dev.coinsquareatm.com/external#mode=kyc&key=\(client.sessionKey)")!)
        webView.load(myRequest)
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }

}

extension URLComponents {
    
    mutating func setQueryItems(with parameters: [String: String]) {
        self.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
    
}
