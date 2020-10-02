
import Foundation
import UIKit
import CashCore

class TopicViewController: UIViewController {
    
    public var topic: Support.Topic?
    
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.contentTextView.text = topic?.content
        self.titleLabel.text = topic?.title
    }
    
}
