
import Foundation

// MARK: Authentication
extension CashCore {
    
    public func createSession(_ listener: SessionCallback?, result: @escaping (Result<GuestLoginResponse, CashCoreError>) -> Void = { _ in }) {
        if listener != nil {
            self.listener = listener
        }
        
        // If I have a session stored on keychain, return it
        if hasSession() {
            if let data = secureStore.getData() {
                self.user = CoreUser.user(from: data)
                    
                self.sessionKey = data[kSessionKey]!
                listener?.onSessionCreated(self.sessionKey)
            }
            return
        }
        requestManager.request(Authentication.guestLogin,
                               headers: headers) { [weak self] res in
            switch res {
            case .success(let data):
                self?.decode(data) { (response: GuestLoginResponse) in
                    if let error = response.error {
                        listener?.onError(error)
                        result(.failure(error))
                        return;
                    }
                    if let session = response.data.sessionKey {
                        self?.sessionKey = session
                        listener?.onSessionCreated(session)
                        result(.success(response))
                    }
                }
                break
            case .failure(let error):
                listener?.onError(error)
                result(.failure(error))
                break
            }
        }
    }
    
    public func login(phone number: String, result: @escaping(Result<BaseResponse, CashCoreError>) -> Void) {
        let params: [String : Any] = ["phone_number": number]
        
        requestManager.request(Authentication.login,
                               body: params,
                               headers: headers) { [weak self] res in
            switch res {
            case .success(let data):
                self?.decode(data) { (response: BaseResponse) in
                    if let error = response.error {
                        if (Int(error.code) == CashCoreErrorCode.sessionTimeout.rawValue) {
                            self?.login(phone: number, result: { (res) in
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
    
    public func loginConfirmation(verification code: String, result: @escaping(Result<BaseResponse, CashCoreError>) -> Void) {
        let params: [String : Any] = ["verification_code": code]
        
        requestManager.request(Authentication.loginConfirmation,
                               body: params,
                               headers: headers) { [weak self] res in
            switch res {
            case .success(let data):
                self?.decode(data) { (response: BaseResponse) in
                    if let error = response.error {
                        if (Int(error.code) == CashCoreErrorCode.sessionTimeout.rawValue) {
                            self?.loginConfirmation(verification: code, result: { (res) in
                                result(res)
                            })
                            return
                        }
                        result(.failure(error))
                    }
                    else {
                        do {
                            try self?.update(user: (self?.user)!)
                            result(.success(response))
                        }
                        catch (_) {
//                            let err = CashCoreError(code: "", message: (exception as! SecureStoreError).errorDescription)
//                            result(.failure(err))
                            return
                        }
                    }
                }
                break
            case .failure(let error):
                result(.failure(error))
                break
            }
        }
    }
    
    public func logout(result: @escaping(Result<BaseResponse, CashCoreError>) -> Void) {
        
        requestManager.request(Authentication.logout,
                               headers: headers) { [weak self] res in
            switch res {
            case .success(let data):
                self?.decode(data) { (response: BaseResponse) in
                    if let error = response.error {
                        if (Int(error.code) == CashCoreErrorCode.sessionTimeout.rawValue) {
                            self?.logout(result: result)
                            return
                        }
                        result(.failure(error))
                    }
                    else {
                        self?.removeSession()
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
    
    public func getUser(result: @escaping(Result<UserResponse, CashCoreError>) -> Void) {
        requestManager.request(Authentication.user,
                               headers: headers) { [weak self] res in
            switch res {
            case .success(let data):
                self?.decode(data) { (response: UserResponse) in
                    if let error = response.error {
                        if (Int(error.code) == CashCoreErrorCode.sessionTimeout.rawValue) {
                            self?.getUser(result: result)
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
    
}
