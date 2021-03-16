
import Foundation

private let userAccount = "CNI"

// MARK: Session
extension ServerEndpoints {
    
    // TODO: Needs to store the phone number the session is associated to as the user may change the phone number while redeeming
    public func setSession() {
        do {
            try self.secureStore.setValue(self.sessionKey, for: userAccount)
        }
        catch (let error) {
            let err = error as! SecureStoreError
            print("Error: \(String(describing: err.errorDescription))")
        }
    }
    
    public func removeSession() {
        do {
            try self.secureStore.removeValue(for: userAccount)
        }
        catch (let error) {
            let err = error as! SecureStoreError
            print("Error: \(String(describing: err.errorDescription))")
        }
    }
    
    public func getSession() -> String? {
        do {
            let sessionKey = try self.secureStore.getValue(for: userAccount)
            return sessionKey
        }
        catch (let error) {
            let err = error as! SecureStoreError
            print("Error: \(String(describing: err.errorDescription))")
            return nil
        }
    }
    
    public func hasSession() -> Bool {
        guard let session = getSession(), !session.isEmpty else {
            return false
        }
        return true
    }
    
}
