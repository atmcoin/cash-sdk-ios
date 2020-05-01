
import Alamofire
import PromiseKit

typealias JSON = [String: Any]
// enum used for convenience purposes (optional)
public enum ServerURL: String {
    case base = "https://secure.just.cash"
}

public protocol SessionCallback {
    func onSessionCreated(_ sessionKey: String)
    func onError(_ errorMessage: String?)
}

open class WAC: WacProtocol  {
    var baseURL: String
    public var sessionKey: String = ""

    var defaultHeader: HTTPHeaders = [
        "Content-Type": "application/json"
    ]

    public init(baseURL: ServerURL = .base) {
        self.baseURL = baseURL.rawValue
    }
    
    var sessionKeyParam: [String:String] {
        get {
            return ["sessionKey": sessionKey]
        }
    }
    
    func decode<T:Decodable>(_ data: Data, completion: @escaping (T) -> ()) {
        let myStruct = try! JSONDecoder().decode(T.self, from: data)
        completion(myStruct)
    }
    
    // API
    
    public func createCashCode(_ atmId: String, _ amount: String, _ verificationCode: String, completion: @escaping (CashCodeResponse) -> ()) {
        var params = ["atm_id": atmId, "amount": amount, "verification_code": verificationCode]
        params.merge(sessionKeyParam, uniquingKeysWith: { $1})
        Request().request(.createCode,
                          parameters: params,
                          headers: defaultHeader)
        .done { data -> Void in
            self.decode(data) { (response: CashCodeResponse) in
                completion(response)
            }
        }
        .catch { error in
            print(error.localizedDescription)
        }
    }
    
    public func checkCashCodeStatus(_ code: String, completion: @escaping (CashCodeStatusResponse) -> ()) {
        Request().request(.checkCodeStatus(code),
                          parameters: sessionKeyParam,
                          headers: defaultHeader)
        .done { data -> Void in
            self.decode(data) { (response: CashCodeStatusResponse) in
                completion(response)
            }
        }
        .catch { error in
            print(error.localizedDescription)
        }
    }
    
    public func createSession(_ listener: SessionCallback) {
        Request().request(.login,
                          headers: defaultHeader)
        .done { data -> Void in
            self.decode(data) { (response: LoginResponse) in
                if let error = response.error {
                    listener.onError(error)
                    return;
                }
                if let session = response.data.sessionKey {
                    self.sessionKey = session
                    listener.onSessionCreated(self.sessionKey)
                }
            }
        }
        .catch { error in
            print(error.localizedDescription)
            listener.onError(error.localizedDescription)
        }
    }
    
    public func getAtmList(completion: @escaping (AtmListResponse) -> ()) {
        Request().request(.getAtmList,
                          parameters: sessionKeyParam,
                          headers: defaultHeader)
        .done { data -> Void in
            self.decode(data) { (response: AtmListResponse) in
                completion(response)
            }
        }
        .catch { error in
            print(error.localizedDescription)
        }
    }
    
    public func getAtmListByLocation(_ latitude: String, _ longitude: String, completion: @escaping (AtmListResponse) -> ()) {
        Request().request(.getAtmListByLocation(latitude, longitude),
                          parameters: sessionKeyParam,
                          headers: defaultHeader)
        .done { data -> Void in
            self.decode(data) { (response: AtmListResponse) in
                completion(response)
            }
        }
        .catch { error in
            print(error.localizedDescription)
        }
    }
  
    public func sendVerificationCode(_ firstName: String, _ lastName: String, phoneNumber: String?, email: String?, completion: @escaping (SendVerificationCodeResponse) -> ()) throws {
        var params = ["first_name": firstName, "last_name": lastName]
      
        if let phoneNumber = phoneNumber, !phoneNumber.isEmpty {
            params["phoneNumber"] = phoneNumber
        }
        
        if let email = email, !email.isEmpty {
             params["email"] = email
        }
        
        if (params["email"] != nil && params["phoneNumber"] != nil) {
          throw InvalidParamsError("Send verication code requires either email or phoneNumber, both are nil.")
        }
       
        params.merge(sessionKeyParam, uniquingKeysWith: {$1})
        Request().request(.sendVerificationCode,
                          parameters: params,
                          headers: defaultHeader)
        .done { data -> Void in
            self.decode(data) { (response: SendVerificationCodeResponse) in
                completion(response)
            }
        }
        .catch { error in
            print(error.localizedDescription)
        }
    }
}
