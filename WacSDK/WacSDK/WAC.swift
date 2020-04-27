
import Alamofire
import PromiseKit

typealias JSON = [String: Any]

// enum used for convenience purposes (optional)
public enum ServerURL: String {
    case base = "https://secure.just.cash"
}

public protocol LoginProtocol {
    func onLogin(_ sessionKey: String)
    func onError(_ errorMessage: String?)
}

open class WAC: NSObject {
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
    
    public func createCode(_ atmId: String, _ amount: String, _ verificationCode: String, completion: @escaping (CashCodeResponse) -> ()) {
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
    
    public func checkCodeStatus(_ code: String, completion: @escaping (CodeStatusResponse) -> ()) {
        Request().request(.checkCodeStatus(code),
                          parameters: sessionKeyParam,
                          headers: defaultHeader)
        .done { data -> Void in
            self.decode(data) { (response: CodeStatusResponse) in
                completion(response)
            }
        }
        .catch { error in
            print(error.localizedDescription)
        }
    }
    
    public func login(_ listener: LoginProtocol) {
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
                    listener.onLogin(self.sessionKey)
                }
            }
        }
        .catch { error in
            print(error.localizedDescription)
            listener.onError(error.localizedDescription)
        }
    }
    
    public func getAtmList(completion: @escaping (ATMListResponse) -> ()) {
        Request().request(.getAtmList,
                          parameters: sessionKeyParam,
                          headers: defaultHeader)
        .done { data -> Void in
            self.decode(data) { (response: ATMListResponse) in
                completion(response)
            }
        }
        .catch { error in
            print(error.localizedDescription)
        }
    }
    
    public func getAtmListByLocation(_ latitude: String, _ longitude: String, completion: @escaping (ATMListResponse) -> ()) {
        Request().request(.getAtmListByLocation(latitude, longitude),
                          parameters: sessionKeyParam,
                          headers: defaultHeader)
        .done { data -> Void in
            self.decode(data) { (response: ATMListResponse) in
                completion(response)
            }
        }
        .catch { error in
            print(error.localizedDescription)
        }
    }
    
    public func sendVerificationCode(_ firstName: String, _ lastName: String, phoneNumber: String = "", email: String = "", completion: @escaping (SendCodeResponse) -> ()) {
        var params = ["first_name": firstName, "last_name": lastName, "phone_number": phoneNumber, "email": email]
        params.merge(sessionKeyParam, uniquingKeysWith: { $1})
        Request().request(.sendVerificationCode,
                          parameters: params,
                          headers: defaultHeader)
        .done { data -> Void in
            self.decode(data) { (response: SendCodeResponse) in
                completion(response)
            }
        }
        .catch { error in
            print(error.localizedDescription)
        }
    }
}
