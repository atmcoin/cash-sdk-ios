
import Foundation

// MARK: User
extension CashCore {
    
    public func add(user: CoreUser) {
        self.user = user
        
        let dict = user.toDictionary()
        secureStore.setData(for: dict)
    }
    
    public func update(user: CoreUser) throws {
        guard let storedUser = secureStore.getData(), CoreUser.user(from: storedUser) == user else {
            throw SecureStoreError.mismatch
        }
        guard var usr = self.user else {
            throw SecureStoreError.notFound
        }
        usr.update(session: self.sessionKey)
        secureStore.updateData(usr.toDictionary())
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
                let documentStatus = documents.getKYCState()
                if documentStatus == KYCState.new {
                    completion(.notVerified)
                    return
                }
                if documentStatus == KYCState.verified {
                    completion(.verified)
                    return
                }
                if documentStatus == KYCState.rejected {
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
