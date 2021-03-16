
import Foundation

public enum CoreTransactionStatus: String, Codable {
    // IMPORTANT: Do not change the values of the cases as User Defaults will cause exceptions if any objects were stored
    case VerifyPending = "New" // Nice to have.
    case SendPending = "Pending" // Note: Could be send from other wallet. After X time, this transaction may be cancelled if not sent
    case Awaiting = "Transaction Sent"
    case FundedNotConfirmed = "Unconfirmed"
    case Funded = "Funded" // It could take some time to be confirmed
    case Withdrawn = "Used"
    case Cancelled = "Cancelled"
    case Error = "Error"

    static func transactionStatus(from status: CodeStatus) -> CoreTransactionStatus {
        switch status {
        case .AWAITING:
            return .Awaiting
        case .FUNDED_NOT_CONFIRMED:
            return .FundedNotConfirmed
        case .FUNDED:
            return .Funded
        case .USED:
            return .Withdrawn
        case .CANCELLED:
            return .Cancelled
        case .ERROR:
            return .Error
        }
    }
    
    // Codable stores the rawValue of the enum in the UserDefaults, hence chaning the rawValue
    // was not an option as retrieving from user defaults would cause an exception
    // This is a helper variable to return the rawValue with some exceptions
    public var displayValue: String {
        if rawValue == "Cancelled" {
            return "Expired"
        }
        return rawValue
    }
}

public struct CoreTransaction: CustomStringConvertible, Codable, Equatable {
    
    public var id: String
    public var timestamp: Double
    public var status: CoreTransactionStatus
    public var atm: AtmMachine?
    public var code: CashCode?
    public var pCode: String?
    public var color: String {
        get {
            return color(for: status)
        }
    }
    
    public init(status: CoreTransactionStatus, atm: AtmMachine? = nil, code: CashCode? = nil) {
        self.id = UUID().uuidString
        self.timestamp = Date().timeIntervalSince1970
        self.status = status
        self.atm = atm
        self.code = code
        self.pCode = nil
    }
    
    public var description: String {
        return "\(id) - \(timestamp) = \(status.rawValue)"
    }

    private func color(for status:CoreTransactionStatus) -> String {
        // Colors have to be 6 characters long
        switch status {
        case .VerifyPending:
            return "f2a900"
        case .SendPending:
            return "f2a900"
        case .Awaiting:
            return "d6ad19"
        case .FundedNotConfirmed:
            return "bbb232"
        case .Funded:
            return "a0b64b"
        case .Withdrawn:
            return "85BB65"
        case .Cancelled:
            return "5e6fa5"
        case .Error:
            return "a55e6f"
        }
    }
    
    public static func == (lhs: CoreTransaction, rhs: CoreTransaction) -> Bool {
        if (hasUniqueIdentifier(lhs) && hasUniqueIdentifier(rhs)) {
            return lhs.id == rhs.id
        }
        return lhs.timestamp == rhs.timestamp
    }
}

extension CoreTransaction {
    static func hasUniqueIdentifier(_ transaction: CoreTransaction) -> Bool {
        let transactionMirror = Mirror(reflecting: transaction)
        for (name, _) in transactionMirror.children {
            guard let name = name else { continue }
            if (name == "id") {
                return true
            }
        }
        return false
    }
}
