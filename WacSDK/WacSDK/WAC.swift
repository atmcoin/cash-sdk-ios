
typealias JSON = [String: Any]

public protocol SessionCallback {
    func onSessionCreated(_ sessionKey: String)
    func onError(_ errorMessage: WacError?)
}

public enum WacUrl: String {
    case Staging = "https://secure.just.cash"
    case Production = "https://api-prd.just.cash"
}

open class WAC: WacProtocol  {
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
    
    public init(url: WacUrl = .Production) {
        requestManager = Request.init(url: url.rawValue)
    }
    
    func decode<T:Decodable>(_ data: Data, completion: @escaping (T) -> ()) {
        let object: Response = try! JSONDecoder().decode(T.self, from: data) as! Response
        if let error = object.error {
            handleSessionExpiry(error) {
                completion(object as! T)
            }
        }
        else {
            completion(object as! T)
        }
    }
    
    // API
    
    public func createCashCode(_ atmId: String, _ amount: String, _ verificationCode: String, completion: @escaping (CashCodeResponse) -> ()) {
        let params = ["atm_id": atmId,
                      "amount": amount,
                      "verification_code": verificationCode]
        
        requestManager.request(.createCode,
                               body: params,
                               headers: headers,
                               completion: { [weak self] data, error in
                                if (error == nil) {
                                    self?.decode(data!) { (response: CashCodeResponse) in
                                        if response.error != nil {
                                            self?.createCashCode(atmId, amount, verificationCode, completion: { (response: CashCodeResponse) in
                                                completion(response)
                                            })
                                        }
                                        else {
                                            completion(response)
                                        }
                                    }
                                }
        })
    }
    
    public func checkCashCodeStatus(_ code: String, completion: @escaping (CashCodeStatusResponse) -> ()) {
        requestManager.request(.checkCodeStatus(code),
                               headers: headers,
                               completion: { [weak self] data, error in
                                if (error == nil) {
                                    self?.decode(data!) { (response: CashCodeStatusResponse) in
                                        if response.error != nil {
                                            self?.checkCashCodeStatus(code, completion: { (response: CashCodeStatusResponse) in
                                                completion(response)
                                            })
                                        }
                                        else {
                                            completion(response)
                                        }
                                    }
                                }
        })
    }
    
    public func createSession(_ listener: SessionCallback, completion: @escaping (() ->())) {
        self.listener = listener
        requestManager.request(.login,
                               headers: headers,
                               completion: { [weak self] data, error in
                                if let data = data {
                                    self?.decode(data) { (response: LoginResponse) in
                                        if let error = response.error {
                                            listener.onError(error)
                                            return;
                                        }
                                        if let session = response.data.sessionKey {
                                            self?.sessionKey = session
                                            listener.onSessionCreated(session)
                                        }
                                        completion()
                                    }
                                }
        })
    }
    
    public func getAtmList(completion: @escaping (AtmListResponse) -> ()) {
        requestManager.request(.getAtmList,
                               headers: headers,
                               completion: { [weak self] data, error in
                                if (error == nil) {
                                    self?.decode(data!) { (response: AtmListResponse) in
                                        if response.error != nil {
                                            self?.getAtmList(completion: { (response: AtmListResponse) in
                                                completion(response)
                                            })
                                        }
                                        else {
                                            completion(response)
                                        }
                                    }
                                }
        })
    }
    
    public func getAtmListByLocation(_ latitude: String, _ longitude: String, completion: @escaping (AtmListResponse) -> ()) {
        requestManager.request(.getAtmListByLocation(latitude, longitude),
                               headers: headers,
                               completion: { [weak self] data, error in
                                if (error == nil) {
                                    self?.decode(data!) { (response: AtmListResponse) in
                                        if response.error != nil {
                                            self?.getAtmListByLocation(latitude, longitude, completion: { (response: AtmListResponse) in
                                                completion(response)
                                            })
                                        }
                                        else {
                                            completion(response)
                                        }
                                    }
                                }
        })
    }
    
    public func isSessionValid(_ sessionKey: String, completion: @escaping ((Bool) -> ())) {
        requestManager.request(.isSessionValid,
                               headers: headers,
                               completion: { data, error in
                                if (error == nil) {
                                    completion(true)
                                }
                                else {
                                    completion(false)
                                }
        })
    }
    
    public func sendVerificationCode(first name: String, surname last: String, phoneNumber: String = "", email: String = "", completion: @escaping (SendVerificationCodeResponse) -> ()) {
        let params: [String : String] = ["first_name": name,
                                         "last_name": last,
                                         "phone_number": phoneNumber,
                                         "email": email]
        requestManager.request(.sendVerificationCode,
                               body: params,
                               headers: headers,
                               completion: { [weak self] data, error in
                                if (error == nil) {
                                    self?.decode(data!) { (response: SendVerificationCodeResponse) in
                                        if response.error != nil {
                                            self?.sendVerificationCode(first: name, surname: last, phoneNumber: phoneNumber, email: email, completion: { (response: SendVerificationCodeResponse) in
                                                completion(response)
                                            })
                                        }
                                        else {
                                            completion(response)
                                        }
                                    }
                                }
        })
    }
    
    private func handleSessionExpiry(_ error: WacError, completion: @escaping (()-> Void)) {
        if (Int(error.code) == WACErrorCode.sessionTimeout.rawValue) {
            createSession(self.listener!) {
                completion()
            }
        }
    }
    
}
