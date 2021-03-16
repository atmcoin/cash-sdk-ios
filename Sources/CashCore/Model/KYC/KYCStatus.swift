
import Foundation

public enum KYCStatus {
    case guest
    case notVerified
    case verifying
    case verified
    case rejected
    case notValid(message: String)
    
    public var statusDescription: String {
        switch self {
        case .guest:
            return "Guest"
        case .notVerified:
            // User has not entered any documents
            return "Identity Not Verified"
        case .verifying:
            // User has entered the documents but these are in pending state
            return "Verifying..."
        case .verified:
            // Documents approved
            return "Verified"
        case .rejected:
            // Documents approved
            return "Rejected"
        case .notValid(let message):
            return message
        }
    }
}
