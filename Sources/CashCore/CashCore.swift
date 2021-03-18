
import Foundation

/// Environments available. Defaults to Production
public enum EnvironmentUrl: String {
    case Staging = "https://secure.just.cash"
    case Production = "https://api-prd.just.cash"
}

public class CashCore {
    
    internal(set) public var sessionKey: String = ""
    internal var requestManager: Request
    internal var listener: SessionCallback?
    internal(set) public var user: CoreUser?
    internal(set) public var support: Support?
    lazy internal(set) public var secureStore: SecureStore = {
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
    internal func decode<T:Decodable>(_ data: Data, completion: @escaping (T) -> ()) {
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
   
