
import Foundation

public enum CashSDKErrorCode: Int {
    case sessionTimeout = 105
}

public struct CashSDKError: Codable {
    public let code: String
    public let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code
        case message = "server_message"
    }
}
