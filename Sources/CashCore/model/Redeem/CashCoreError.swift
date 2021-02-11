
import Foundation

public enum CashCoreErrorCode: Int {
    // Server Defined End Point Errors
    case sessionTimeout = 105
    
    case wrongVerificationCode = 2001
    case tooManyVerificationCodeAttempts = 2002
    case verificationCodeExpired = 2003
    
    // Local Defined End Point Errors
    case invalidEndPoint = 20001    // A 
    case invalidResponse = 20002
    case corruptedResponse = 20003
}

public struct CashCoreError: Codable, Error {
    public let code: String
    public let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code
        case message = "server_message"
    }
}
