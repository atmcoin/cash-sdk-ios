
import Foundation

public protocol SessionCallback {
    func onSessionCreated(_ sessionKey: String)
    func onError(_ error: CashCoreError?)
}

// MARK: Session
extension CashCore {
    
    public func getSession() -> String? {
        guard let data = secureStore.getData() else {
            return nil
        }
        return data[kSessionKey]
    }
    
    public func hasSession() -> Bool {
        guard let session = getSession(), !session.isEmpty else {
            return false
        }
        return true
    }
    
    public func removeSession() {
        guard var data = secureStore.getData() else {
            return
        }
        data[kSessionKey] = ""
        secureStore.setData(for: data)
    }
    
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
    
}
