
import UIKit
import CashCore

class LoginViewController: UIViewController {
    
    public var client: ServerEndpoints!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var sessionKeyLabel: UILabel!
    
    @IBOutlet var sessionButton: UIButton!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet var phoneNumberTextfield: UITextField!
    @IBOutlet var registerButton: UIButton!
    
    @IBOutlet var verificationCodeTextfield: UITextField!
    @IBOutlet var loginConfirmationButton: UIButton!
    
    @IBOutlet var statusButton: UIButton!
    @IBOutlet var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if client.hasSession() {
            self.sessionButton.setTitle("Get Session", for: .normal)
            self.registerButton.setTitle("Login", for: .normal)
            self.registerButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        }
        else {
            self.sessionButton.setTitle("Create Session", for: .normal)
            self.registerButton.setTitle("Register", for: .normal)
            self.registerButton.addTarget(self, action: #selector(registerButtonPressed), for: .touchUpInside)
        }
        
        self.registerButton.isEnabled = false
        self.loginConfirmationButton.isEnabled = false
        self.statusButton.isEnabled = false
    }
    
    @IBAction func createSession(_ sender: Any) {
        let listener = self
        client.createSession(listener)
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        client.login(phone: phoneNumberTextfield.text!) { [weak self] (result) in
            switch result {
            case .success(_):
                self?.showAlert("Success", message: "Enter the verification code sent to you via SMS")
                break
            case .failure(let error):
                self?.showAlert("Error", message: (error.message)!)
                break
            }
        }
    }
    
    @IBAction func loginConfirmationButtonPressed(_ sender: Any) {
        client.loginConfirmation(verification: verificationCodeTextfield.text!) { [weak self] (result) in
            switch result {
            case .success(_):
                self?.statusButton.isEnabled = true
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let webViewController = storyboard.instantiateViewController(withIdentifier: "webViewController") as! WebViewController
                webViewController.client = self?.client
                self?.present(webViewController, animated: true, completion: nil)
                break
            case .failure(let error):
                self?.showAlert("Error", message: (error.message)!)
                break
            }
        }
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        let firstName = self.firstNameTextField.text!
        let lastName = self.lastNameTextField.text!
        let phone = self.phoneNumberTextfield.text!
        client.register(first: firstName, surname: lastName, phone: phone) { [weak self] result in
            switch result {
            case .success(_):
                self?.showAlert("Success", message: "Enter the verification code sent to you via SMS")
                break
            case .failure(let error):
                self?.showAlert("Error", message: (error.message)!)
                break
            }
        }
    }
    
    @IBAction func getStatusButtonPressed(_ sender: Any) {
//        client.getUserStatus() { [weak self] status in
        client.getUserStatusSimplified() { [weak self] status in
            self?.statusLabel.text = status.statusDescription
        }
    }
    
    @IBAction func textDidChangeVerificationCode(_ sender: Any) {
        let code = self.verificationCodeTextfield.text
        if (code != "") {
            self.loginConfirmationButton.isEnabled = true
        }
        else {
            self.loginConfirmationButton.isEnabled = false
        }
    }
    
    @IBAction func registerTextFieldDidChange(_ sender: Any) {
        if client.sessionKey.isEmpty {
            self.showAlert("Error", message: "Please create a session before continuing")
            return
        }
        let firstName = self.firstNameTextField.text!
        let lastName = self.lastNameTextField.text!
        let phone = self.phoneNumberTextfield.text!
        if (!client.sessionKey.isEmpty && firstName != "" && lastName != "" && phone != "") {
            self.registerButton.isEnabled = true
        }
        else {
            self.registerButton.isEnabled = false
        }
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

extension LoginViewController: SessionCallback {
    // Login Protocol Implementation
    
    func onSessionCreated(_ sessionKey: String) {
        print(sessionKey)
        self.sessionKeyLabel.text = sessionKey
    }
    
    func onError(_ error: CashCoreError?) {
        showAlert("Error", message: (error?.message)!)
    }
}
