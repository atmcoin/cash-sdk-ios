
import Foundation

public protocol CoreSessionManagerDelegate {
    /// 
    func sendCoin(amount: String, address: String, completion: @escaping (() -> Void))
}

public class CoreSessionManager {
    
    public static let shared: CoreSessionManager = {
        let instance = CoreSessionManager()
        return instance
    }()
    
    public var delegate: CoreSessionManagerDelegate?
    public var client: ServerEndpoints? = nil
    
    public init() {}
    
    public func start(url: EnvironmentUrl = .Production) {
        client = ServerEndpoints.init(url: url)
        
        client!.createSession(self)
        CoreTransactionManager.startPolling()
    }
}

extension CoreSessionManager: SessionCallback {

    public func onSessionCreated(_ sessionKey: String) {
        NotificationCenter.default.post(name: .CoreSessionDidStart, object: nil)
    }

    public func onError(_ error: CashCoreError?) {
        NotificationCenter.default.post(name: .CoreSessionDidFail, object: error)
    }

}

extension Notification.Name {

    public static let CoreSessionDidStart = Notification.Name(rawValue: "CoreSessionDidStart")
    public static let CoreSessionDidFail = Notification.Name(rawValue: "CoreSessionDidFail")
}
