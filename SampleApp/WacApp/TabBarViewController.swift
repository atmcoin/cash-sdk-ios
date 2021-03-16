
import Foundation
import UIKit
import CashCore

class TabBarViewController: UITabBarController {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let client = ServerEndpoints.init(url: .Staging)
        
        var navController = self.viewControllers?.first as! UINavigationController
        let loginController = navController.topViewController as! LoginViewController
        loginController.client = client
        
        navController = self.viewControllers?[1] as! UINavigationController
        let redeemController = navController.topViewController as! RedeemViewController
        redeemController.client = client
        
        navController = self.viewControllers?.last as! UINavigationController
        let supportController = navController.topViewController as! SupportTableViewController
        supportController.client = client
    }
}
