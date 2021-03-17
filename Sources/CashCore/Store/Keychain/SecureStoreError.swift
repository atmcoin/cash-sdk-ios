
import Foundation

public enum SecureStoreError: Error {
    case conversionError(message: String)
    case unhandledError(message: String)
}

extension SecureStoreError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .conversionError(let message):
            return NSLocalizedString(message, comment: "Secure Store Error")
        case .unhandledError(let message):
            return NSLocalizedString(message, comment: "Secure Store Error")
        }
    }
}
