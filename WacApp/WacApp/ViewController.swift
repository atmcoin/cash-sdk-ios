
import UIKit
import WacSDK

class ViewController: UIViewController, SessionCallback {
    
    private var client: WAC!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var sessionKeyLabel: UILabel!
    // ATM List
    @IBOutlet weak var atmListButton: UIButton!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var atmListTextView: UITextView!
    // Verification Code
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var telephoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    // Create pCode
    @IBOutlet weak var atmIdTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var createCodeSendButton: UIButton!
    // Check pCode
    @IBOutlet weak var pCodeTextField: UITextField!
    @IBOutlet weak var checkPCodeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        toggleViewsAfterLogin(false)
        
        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Disable buttons until criteria is met
        self.sendButton.isEnabled = false
        self.createCodeSendButton.isEnabled = false
        self.checkPCodeButton.isEnabled = false
    }
    
    func toggleViewsAfterLogin(_ enabled: Bool) {
        self.atmListButton.isEnabled = enabled
        self.latitudeTextField.isEnabled = enabled
        self.longitudeTextField.isEnabled = enabled
        
        self.firstNameTextField.isEnabled = enabled
        self.lastNameTextField.isEnabled = enabled
        self.telephoneTextField.isEnabled = enabled
        self.emailTextField.isEnabled = enabled
        
        self.atmIdTextField.isEnabled = enabled
        self.amountTextField.isEnabled = enabled
        self.codeTextField.isEnabled = enabled
        
        self.pCodeTextField.isEnabled = enabled
    }
    
    // Implement WAC
    
    @IBAction func createCashCode(_ sender: Any) {
        client.createCashCode(atmIdTextField.text!, amountTextField.text!, codeTextField.text!, completion: { (response: CashCodeResponse) in
            if (response.result == "ok") {
                self.pCodeTextField.text = response.data?.items?[0].secureCode!
                self.checkPCodeButton.isEnabled = true
            }
            else {
                self.showAlert("Error", message: (response.error?.message)!)
            }
        })
    }
    
    @IBAction func checkCodeStatus(_ sender: Any) {
        client.checkCashCodeStatus(pCodeTextField.text!, completion: { (response: CashCodeStatusResponse) in
            if (response.result == "error") {
                let message = response.error?.message
                self.showAlert("Error", message: message!)
            }
            else {
                self.showAlert("Result", message: response.result)
            }
        })
    }
    
    @IBAction func createSession(_ sender: Any) {
        client = WAC.init()
        let listener = self
        client.createSession(listener)
        
        toggleViewsAfterLogin(true)
    }
    
    @IBAction func getAtmListBy(_ sender: Any) {
        let latitude = self.latitudeTextField.text!
        let longitude =  self.longitudeTextField.text!
        if (latitude != "" && longitude != "") {
            getAtmListByLocation(latitude, longitude)
        }
        else {
            getAtmList()
        }
    }
    
    @IBAction func sendVerificationCode(_ sender: Any) {
        client.sendVerificationCode(first: firstNameTextField.text!, surname: lastNameTextField.text!, phoneNumber: telephoneTextField.text!, email: emailTextField.text!, completion: { (response: SendVerificationCodeResponse) in
            if (response.result == "error") {
                let message = response.error?.message
                self.showAlert("Error", message: message!)
            }
        })
    }
    
    // ATM picker
    
    func getAtmListByLocation(_ latitude: String, _ longitude: String) {
        client.getAtmListByLocation(latitude, longitude, completion: { (response: AtmListResponse) in
            self.atmListTextView.text = String(describing: response)
        })
    }
    
    func getAtmList() {
        client.getAtmList(completion: { (response: AtmListResponse) in
            self.atmListTextView.text = String(describing: response)
        })
    }
    
    // Login Protocol Implementation
    
    func onSessionCreated(_ sessionKey: String) {
        print(sessionKey)
        self.sessionKeyLabel.text = sessionKey
    }
    
    func onError(_ errorMessage: String?) {
        showAlert("Error", message: errorMessage!)
    }
    
    // Enforce certain fields to have content
    
    @IBAction func textDidChangeAtmList(_ sender: Any) {
        let latitude = self.latitudeTextField.text
        let longitude =  self.longitudeTextField.text
        if (latitude != "" && longitude != "") {
            self.atmListButton.setTitle("By Location", for: .normal)
        }
        else {
            self.atmListButton.setTitle("All", for: .normal)
        }
    }
    
    @IBAction func textDidChangeVerificationCode(_ sender: Any) {
        let phone = self.telephoneTextField.text
        let email = self.emailTextField.text
        if (phone != "" || email != "") {
            self.sendButton.isEnabled = true
        }
        else {
            self.sendButton.isEnabled = false
        }
    }
    
    @IBAction func textDidChangeCheckCode(_ sender: Any) {
        let atmId = self.atmIdTextField.text
        let amount =  self.amountTextField.text
        let code =  self.codeTextField.text
        if (atmId != "" && amount != "" && code != "") {
            self.createCodeSendButton.isEnabled = true
        }
        else {
            self.createCodeSendButton.isEnabled = false
        }
    }
    
    @IBAction func textDidChangeCreateCode(_ sender: Any) {
        let atmId = pCodeTextField.text
        if (atmId != "") {
            self.checkPCodeButton.isEnabled = true
        }
        else {
            self.checkPCodeButton.isEnabled = false
        }
    }
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Keyboard
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = .zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
