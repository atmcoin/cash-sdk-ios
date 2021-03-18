
import Foundation

public enum SecureStoreError: Error {
    case conversionError(message: String)
    case unhandledError(message: String)
    case mismatch
    case notFound
}

extension SecureStoreError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notFound:
            return NSLocalizedString("User Not Found", comment: "Secure Store Error")
        case .mismatch:
            return NSLocalizedString("User stored mistmaches the user you are trying to modify", comment: "Secure Store Error")
        case .conversionError(let message):
            return NSLocalizedString(message, comment: "Secure Store Error")
        case .unhandledError(let message):
            return NSLocalizedString(message, comment: "Secure Store Error")
        }
    }
}
