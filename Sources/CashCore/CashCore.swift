
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

public class ServerEndpoints  {
    
    public var sessionKey: String = ""
    var requestManager: Request
    var listener: SessionCallback?
    public var userData: [AnyHashable: String]?
    public var support: Support?
    lazy var secureStore: SecureStore = {
        let secureStoreQueryable = GenericPasswordQueryable.init(service: "Login")
        let store = SecureStore.init(secureStoreQueryable: secureStoreQueryable)
        return store
    }()
    
    public var headers: [String: String] {
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
    public func decode<T:Decodable>(_ data: Data, completion: @escaping (T) -> ()) {
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
    
}

// MARK: Helpers
extension ServerEndpoints {
    
    public func handleSessionExpiry(_ error: CashCoreError, completion: @escaping (()-> Void)) {
        // On session expiry - error code 105:
        //  1. get a session key through guest login
        //  2. login with phone number - Do not do for now
        //  3. confirm with code - Do not do for now
        
        // If session expires, we can only renew a guest session. Logout to remove keychain session
        self.logout() { [weak self] _ in
            self?.createSession(self?.listener) { _ in
                completion()
            }
        }
    }
    
    public func getUserStatus(completion: @escaping (KYCStatus) -> Void) {
        if !hasSession() {
            return completion(.guest)
        }
        getKYCDocuments() { result in
            switch result {
            case .success(let response):
                guard let documents = response.data?.items else {
                    completion(.notValid(message: "Error: kyc/status items was nil"))
                    return
                }
                if documents.count == 0 {
                    // Have not uploaded any documents
                    completion(.notVerified)
                    return
                }
                for doc in documents {
                    if doc.getDocumentStatus() == .pending {
                        // At least one of the documents is Pending
                        completion(.verifying)
                        return
                    }
                    if doc.getDocumentStatus() == .rejected {
                        // At least one of the documents got rejected
                        completion(.rejected)
                        return
                    }
                }
                // All documents have been accepted
                completion(.verified)
                
            case .failure(_):
                // Response Error
                completion(.notValid(message: "Error: kyc/status response failure"))
                break
            }
        }
    }
    
    public func getUserStatusSimplified(completion: @escaping (KYCStatus) -> Void) {
        if !hasSession() {
            completion(.guest)
            return
        }
        getKYCStatus() { result in
            switch result {
            case .success(let response):
                guard let documents: KYCItem = response.data?.items.first else {
                    completion(.notValid(message: "Error: kyc/status items was nil"))
                    return
                }
                if documents.getKYCDocumentsStatus() == KYCDocumentsStatus.new {
                    completion(.notVerified)
                    return
                }
                if documents.getKYCDocumentsStatus() == KYCDocumentsStatus.verified {
                    completion(.verified)
                    return
                }
                if documents.getKYCDocumentsStatus() == KYCDocumentsStatus.rejected {
                    completion(.rejected)
                    return
                }
            case .failure(_):
                // Response Error
                completion(.notValid(message: "Error: kyc/status response failure"))
                break
            }
        }
    }
}
   
