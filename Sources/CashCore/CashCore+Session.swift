
import Foundation

private let userAccount = "CNI"


public let kFirstName = "firstName"
public let kLastName = "lastName"
public let kPhoneNumber = "phoneNumber"
public let kEmail = "email"
public let kSessionKey = "sessionKey"

// MARK: Session
extension ServerEndpoints {
    
    public func setSession(for object: [AnyHashable: String]) {
        do {
            var dict = object
            dict.updateValue(self.sessionKey, forKey: kSessionKey)
            try self.secureStore.setValue(dict, for: userAccount)
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
        guard let data = getData() else {
            return nil
        }
        return data[kSessionKey]
    }
    
    public func getData() -> [AnyHashable: String]? {
        do {
            let data = try self.secureStore.getValue(for: userAccount)
            return data
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
