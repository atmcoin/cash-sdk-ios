
import Foundation

// MARK: Redeem Flow
extension CashCore {
    
    public func createCashCode(_ atmId: String, _ amount: String, _ verificationCode: String, result: @escaping (Result<CashCodeResponse, CashCoreError>) -> Void) {
        let params = ["atm_id": atmId,
                      "amount": amount,
                      "verification_code": verificationCode]
        
        requestManager.request(Redeem.createCode,
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
        requestManager.request(Redeem.checkCodeStatus(code),
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
    
    public func getAtmList(result: @escaping (Result<AtmListResponse, CashCoreError>) -> Void) {
        requestManager.request(Redeem.atmList,
                               headers: headers) { [weak self] res in
            switch res {
            case .success(let data):
                self?.decode(data) { (response: AtmListResponse) in
                    if let error = response.error {
                        if (Int(error.code) == CashCoreErrorCode.sessionTimeout.rawValue) {
                            self?.getAtmList(result: result)
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
        requestManager.request(Redeem.atmListByLocation(latitude, longitude),
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
    
    public func sendVerificationCode(first name: String, surname last: String, phoneNumber: String, email: String, result: @escaping (Result<VerificationCodeResponse, CashCoreError>) -> Void) {
        let params: [String : Any] = ["first_name": name,
                                      "last_name": last,
                                      "phone_number": phoneNumber,
                                      "email": email,
                                      "word_code": 1]
        requestManager.request(Redeem.verifyCode,
                               body: params,
                               headers: headers) { [weak self] res in
            switch res {
            case .success(let data):
                self?.decode(data) { (response: VerificationCodeResponse) in
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
    
}
