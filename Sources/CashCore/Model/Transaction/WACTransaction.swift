import Foundation

// This is a deprecated version of the Transactions
public struct WACTransaction: CustomStringConvertible, Codable, Equatable {
    
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
        self.timestamp = Date().timeIntervalSince1970
        self.status = status
        self.atm = atm
        self.code = code
        self.pCode = nil
    }
    
    public var description: String {
        return "\(timestamp) = \(status.rawValue)"
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
    
    public static func == (lhs: WACTransaction, rhs: WACTransaction) -> Bool {
        return lhs.timestamp == rhs.timestamp
    }
}

