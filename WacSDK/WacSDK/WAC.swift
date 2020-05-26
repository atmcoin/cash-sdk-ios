
typealias JSON = [String: Any]

public protocol SessionCallback {
    func onSessionCreated(_ sessionKey: String)
    func onError(_ errorMessage: String?)
}

open class WAC: WacProtocol  {
    public var sessionKey: String = ""
    private var requestManager: Request

    private var headers: [String: String] {
        get {
            return [
                "Content-Type": "application/json",
                "sessionKey": sessionKey
            ]
        }
    }

    public init(url: String = "https://secure.just.cash") {
        requestManager = Request.init(url: url)
    }
    
    func decode<T:Decodable>(_ data: Data, completion: @escaping (T) -> ()) {
        let myStruct = try! JSONDecoder().decode(T.self, from: data)
        completion(myStruct)
    }
    
    // API
    
    public func createCashCode(_ atmId: String, _ amount: String, _ verificationCode: String, completion: @escaping (CashCodeResponse) -> ()) {
          let params = ["atm_id": atmId,
                        "amount": amount,
                        "verification_code": verificationCode]
        
        requestManager.request(.createCode,
                                body: params,
                                headers: headers,
                                completion: { data, error in
                                    if (error == nil) {
                                        self.decode(data!) { (response: CashCodeResponse) in
                                            completion(response)
                                        }
                                    }
                                    else {
                                        print(error!.localizedDescription)
                                    }
        })
      }
      
    public func checkCashCodeStatus(_ code: String, completion: @escaping (CashCodeStatusResponse) -> ()) {
        requestManager.request(.checkCodeStatus(code),
                                headers: headers,
                                completion: { data, error in
                                    if (error == nil) {
                                        self.decode(data!) { (response: CashCodeStatusResponse) in
                                            completion(response)
                                        }
                                    }
                                    else {
                                        print(error!.localizedDescription)
                                    }
        })
    }
    
    public func createSession(_ listener: SessionCallback) {
        requestManager.request(.login,
                                headers: headers,
                                completion: { data, error in
                                    if let data = data {
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
        })
    }
    
    public func getAtmList(completion: @escaping (AtmListResponse) -> ()) {
        requestManager.request(.getAtmList,
                                headers: headers,
                                completion: { data, error in
                                    if (error == nil) {
                                        self.decode(data!) { (response: AtmListResponse) in
                                            completion(response)
                                        }
                                    }
                                    else {
                                        print(error!.localizedDescription)
                                    }
        })
    }
    
    public func getAtmListByLocation(_ latitude: String, _ longitude: String, completion: @escaping (AtmListResponse) -> ()) {
        requestManager.request(.getAtmListByLocation(latitude, longitude),
                                headers: headers,
                                completion: { data, error in
                                    if (error == nil) {
                                        self.decode(data!) { (response: AtmListResponse) in
                                            completion(response)
                                        }
                                    }
                                    else {
                                        print(error!.localizedDescription)
                                    }
        })
    }
    
    public func sendVerificationCode(first name: String, surname last: String, phoneNumber: String = "", email: String = "", completion: @escaping (SendVerificationCodeResponse) -> ()) {
        let params: [String : String] = ["first_name": name,
                      "last_name": last,
                      "phone_number": phoneNumber,
                      "email": email]
        
//        if (params["email"] == nil && params["phone_number"] == nil) {
//            throw InvalidParamsError("Send verication code requires either email or phoneNumber, both are nil.")
//        }
        requestManager.request(.sendVerificationCode,
                               body: params,
                                headers: headers,
                                completion: { data, error in
                                    if (error == nil) {
                                        self.decode(data!) { (response: SendVerificationCodeResponse) in
                                            completion(response)
                                        }
                                    }
                                    else {
                                        print(error!.localizedDescription)
                                    }
        })
    }
    
}
