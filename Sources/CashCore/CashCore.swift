
import Foundation

public protocol SessionCallback {
    func onSessionCreated(_ sessionKey: String)
    func onError(_ error: CashCoreError?)
}

/// Environments available. Defaults to Production
public enum EnvironmentUrl: String {
    case Staging = "https://secure.just.cash"
    case Production = "https://api-prd.just.cash"
}

public class ServerEndpoints: EndPoints  {
    
    public var sessionKey: String = ""
    private var requestManager: Request
    private var listener: SessionCallback?
    
    private var headers: [String: String] {
        get {
            return [
                "Content-Type": "application/json",
                "sessionKey": sessionKey
            ]
        }
    }
    
    public init(url: EnvironmentUrl = .Production) {
        requestManager = Request.init(url: url.rawValue)
    }
    
    
    /// Generic way of decoding data responses
    /// - Parameters:
    ///   - data: the data to be decoded
    ///   - completion: the completion block that handles the Object in the response
    func decode<T:Decodable>(_ data: Data, completion: @escaping (T) -> ()) {
        let object: Response = try! JSONDecoder().decode(T.self, from: data) as! Response
        if let error = object.error {
            // When session key has timed out, refresh the token and try again.
            if (Int(error.code) == CashCoreErrorCode.sessionTimeout.rawValue) {
                handleSessionExpiry(error) {
                    completion(object as! T)
                }
                return;
            }
            completion(object as! T)
        }
        else {
            completion(object as! T)
        }
    }
    
    // API
    
    public func createCashCode(_ atmId: String, _ amount: String, _ verificationCode: String, result: @escaping (Result<CashCodeResponse, CashCoreError>) -> Void) {
        let params = ["atm_id": atmId,
                      "amount": amount,
                      "verification_code": verificationCode]
        
        requestManager.request(.createCode,
                               body: params,
                               headers: headers) { [weak self] res in
                                switch res {
                                case .success(let data):
                                    self?.decode(data) { (response: CashCodeResponse) in
                                        if let error = response.error {
                                            if (Int(error.code) == CashCoreErrorCode.sessionTimeout.rawValue) {
                                                self?.createCashCode(atmId, amount, verificationCode, result: result)
                                                return;
                                            }
                                            result(.failure(error))
                                        }
                                        else {
                                            result(.success(response))
                                        }
                                    }
                                    break
                                case .failure(let error):
                                    result(.failure(error))
                                    break
                                }
        }
    }
    
    public func checkCashCodeStatus(_ code: String, result: @escaping (Result<CashCodeStatusResponse, CashCoreError>) -> Void) {
        requestManager.request(.checkCodeStatus(code),
                               headers: headers) { [weak self] res in
                                switch res {
                                case .success(let data):
                                    self?.decode(data) { (response: CashCodeStatusResponse) in
                                        if let error = response.error {
                                            if (Int(error.code) == CashCoreErrorCode.sessionTimeout.rawValue) {
                                                self?.checkCashCodeStatus(code, result: { (res) in
                                                    result(res)
                                                })
                                                return
                                            }
                                            result(.failure(error))
                                        }
                                        else {
                                            result(.success(response))
                                        }
                                    }
                                    break
                                case .failure(let error):
                                    result(.failure(error))
                                    break
                                }
        }
    }
    
    public func createSession(_ listener: SessionCallback) {
        self.listener = listener
        requestManager.request(.login,
                               headers: headers) { [weak self] res in
                                switch res {
                                case .success(let data):
                                    self?.decode(data) { (response: LoginResponse) in
                                        if let error = response.error {
                                            listener.onError(error)
                                            return;
                                        }
                                        if let session = response.data.sessionKey {
                                            self?.sessionKey = session
                                            listener.onSessionCreated(session)
                                        }
                                    }
                                    break
                                case .failure(let error):
                                    listener.onError(error)
                                    break
                                }
        }
    }
    
    public func getAtmList(result: @escaping (Result<AtmListResponse, CashCoreError>) -> Void) {
        requestManager.request(.getAtmList,
                               headers: headers) { [weak self] res in
                                switch res {
                                case .success(let data):
                                    self?.decode(data) { (response: AtmListResponse) in
                                        if let error = response.error {
                                            if (Int(error.code) == CashCoreErrorCode.sessionTimeout.rawValue) {
                                                self?.getAtmList(result: { (res) in
                                                    result(res)
                                                })
                                                return
                                            }
                                            result(.failure(error))
                                        }
                                        else {
                                            result(.success(response))
                                        }
                                    }
                                    break
                                case .failure(let error):
                                    result(.failure(error))
                                    break
                                }
        }
    }
    
    public func getAtmListByLocation(_ latitude: String, _ longitude: String, result: @escaping (Result<AtmListResponse, CashCoreError>) -> Void) {
        requestManager.request(.getAtmListByLocation(latitude, longitude),
                               headers: headers) { [weak self] res in
                                switch res {
                                case .success(let data):
                                    self?.decode(data) { (response: AtmListResponse) in
                                        if let error = response.error {
                                            if (Int(error.code) == CashCoreErrorCode.sessionTimeout.rawValue) {
                                                self?.getAtmListByLocation(latitude, longitude, result: { (res) in
                                                    result(res)
                                                })
                                                return
                                            }
                                            result(.failure(error))
                                        }
                                        else {
                                            result(.success(response))
                                        }
                                    }
                                    break
                                case .failure(let error):
                                    result(.failure(error))
                                    break
                                }
        }
    }
    
    public func isSessionValid(_ sessionKey: String, completion: @escaping ((Bool) -> ())) {
        requestManager.request(.isSessionValid,
                               headers: headers) { res in
                                switch res {
                                case .success(_):
                                    completion(true)
                                    break
                                case .failure(_):
                                    completion(false)
                                    break
                                }
        }
    }
    
    public func sendVerificationCode(first name: String, surname last: String, phoneNumber: String, email: String, result: @escaping (Result<SendVerificationCodeResponse, CashCoreError>) -> Void) {
        let params: [String : String] = ["first_name": name,
                                         "last_name": last,
                                         "phone_number": phoneNumber,
                                         "email": email]
        requestManager.request(.sendVerificationCode,
                               body: params,
                               headers: headers) { [weak self] res in
                                switch res {
                                case .success(let data):
                                    self?.decode(data) { (response: SendVerificationCodeResponse) in
                                        if let error = response.error {
                                            if (Int(error.code) == CashCoreErrorCode.sessionTimeout.rawValue) {
                                                self?.sendVerificationCode(first: name, surname: last, phoneNumber: phoneNumber, email: email, result: { (res) in
                                                    result(res)
                                                })
                                                return
                                            }
                                            result(.failure(error))
                                        }
                                        else {
                                            result(.success(response))
                                        }
                                    }
                                    break
                                case .failure(let error):
                                    result(.failure(error))
                                    break
                                }
        }
    }
    
    private func handleSessionExpiry(_ error: CashCoreError, completion: @escaping (()-> Void)) {
        createSession(self.listener!)
    }
    
}
