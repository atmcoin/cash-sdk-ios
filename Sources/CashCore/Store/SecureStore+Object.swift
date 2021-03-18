
import Foundation

private let userAccount = "CNI"


public let kFirstName = "firstName"
public let kLastName = "lastName"
public let kPhoneNumber = "phoneNumber"
public let kEmail = "email"
public let kSessionKey = "sessionKey"

// MARK: Session
extension SecureStore {
    
    public func setData(for object: [AnyHashable: String]) {
        do {
            try self.setValue(object, for: userAccount)
        }
        catch (let error) {
            let err = error as! SecureStoreError
            print("Error: \(String(describing: err.errorDescription))")
        }
    }
    
    public func updateData(_ object: [AnyHashable: String]) {
        guard var data = self.getData() else {
            return
        }
        data[kSessionKey] = object[kSessionKey]
        setData(for: data)
    }
    
    public func removeData() {
        do {
            try self.removeValue(for: userAccount)
        }
        catch (let error) {
            let err = error as! SecureStoreError
            print("Error: \(String(describing: err.errorDescription))")
        }
    }
    
    public func getData() -> [AnyHashable: String]? {
        do {
            let data = try self.getValue(for: userAccount)
            return data
        }
        catch (let error) {
            let err = error as! SecureStoreError
            print("Error: \(String(describing: err.errorDescription))")
            return nil
        }
    }
    
}
