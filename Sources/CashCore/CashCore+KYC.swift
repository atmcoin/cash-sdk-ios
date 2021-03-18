
import Foundation

// MARK: KYC
extension CashCore {

    public func register(first name: String, surname last: String, phone number: String, result: @escaping(Result<BaseResponse, CashCoreError>) -> Void) {
        let params: [String : Any] = ["first_name": name,
                                      "last_name": last,
                                      "phone_number": number]
        
        let usr = CoreUser(firstName: name, lastName: last, phone: number)
        add(user: usr)
        
        requestManager.request(KYC.register,
                               body: params,
                               headers: headers) { [weak self] res in
            switch res {
            case .success(let data):
                self?.decode(data) { (response: BaseResponse) in
                    if let error = response.error {
                        if (Int(error.code) == CashCoreErrorCode.sessionTimeout.rawValue) {
                            self?.register(first: name, surname: last, phone: number, result: result)
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
    
    public func getKYCStatus(result: @escaping(Result<KYCStatusResponse, CashCoreError>) -> Void) {
        
        requestManager.request(KYC.status,
                               headers: headers) { [weak self] res in
            switch res {
            case .success(let data):
                self?.decode(data) { (response: KYCStatusResponse) in
                    if let error = response.error {
                        if (Int(error.code) == CashCoreErrorCode.sessionTimeout.rawValue) {
                            self?.getKYCStatus(result: result)
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
    
    public func getKYCDocuments(result: @escaping(Result<KYCDocumentsResponse, CashCoreError>) -> Void) {
        
        requestManager.request(KYC.documents,
                               headers: headers) { [weak self] res in
            switch res {
            case .success(let data):
                self?.decode(data) { (response: KYCDocumentsResponse) in
                    if let error = response.error {
                        if (Int(error.code) == CashCoreErrorCode.sessionTimeout.rawValue) {
                            self?.getKYCDocuments(result: result)
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

// MARK: Support Pages
extension CashCore {
    
    public func loadJson(fileName: String, bundle: Bundle? = nil) {
        let decoder = JSONDecoder()
        let bundl = bundle ?? Bundle.module
        guard let url = bundl.url(forResource: fileName, withExtension: "json") else {
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let support = try decoder.decode(Support.self, from: data)
            self.support = support
        } catch (let exception) {
            print("Exception: Parsing support pages json failed with \(exception)")
            return
        }
    }
    
}
