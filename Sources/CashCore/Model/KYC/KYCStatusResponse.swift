
import Foundation

public struct KYCStatusResponse: Response, Codable {
    public let result: String
    public let error: CashCoreError?
    public let data: KYCItems?
}

public struct KYCItems: Codable {
    public let items: [KYCItem]
}

public struct KYCItem: Codable {
    public let status: String?
    public let purchaseDailyCountLimit: String?
    public let purchaseDailyAmountLimit: String?
    public let purchaseTxAmountLimit: String?
    public let purchaseRemainCount: String?
    public let redemptionDailyCountLimit: String?
    public let redemptionDailyAmountLimit: String?
    public let redemptionTxAmountLimit: String?
    public let redemptionRemainCount: String?
    public let redemptionRemainAmount: String?
    public let hasPersonalInfo: String?
    public let pendingDocuments: String?
    public let rejectedDocuments: String?
    public let acceptedDocuments: String?
    public let requiredDocuments: String?

    enum CodingKeys: String, CodingKey {
        case status
        case purchaseDailyCountLimit = "pur_daily_count_limit"
        case purchaseDailyAmountLimit = "pur_daily_amount_limit"
        case purchaseTxAmountLimit = "pur_tx_amount_limit"
        case purchaseRemainCount = "pur_remain_count"
        case redemptionDailyCountLimit = "red_daily_count_limit"
        case redemptionDailyAmountLimit = "red_daily_amount_limit"
        case redemptionTxAmountLimit = "red_tx_amount_limit"
        case redemptionRemainCount = "red_remain_count"
        case redemptionRemainAmount = "red_remain_amount"
        case hasPersonalInfo = "has_pi"
        case pendingDocuments = "docs_pending"
        case rejectedDocuments = "docs_rejected"
        case acceptedDocuments = "docs_accepted"
        case requiredDocuments = "docs_required"
    }
    
    public func getKYCState() -> KYCState? {
        for code in KYCState.allCases {
            if (code.rawValue == status) {
                return code
            }
        }
        return nil
    }
    
    // NOTE: This new values look like trouble as they may cause issues
    public func getKYCDocumentsStatus() -> KYCStatus {
        if let accepted = acceptedDocuments, let required = requiredDocuments, accepted == required {
            return .verified
        }
        if let rejected = rejectedDocuments, Int(rejected)! > 0 {
            return .rejected
        }
        if let pending = pendingDocuments, Int(pending)! > 0 {
            return .verifying
        }
        if let hasPi = hasPersonalInfo, Int(hasPi) == 1 {
            return .notVerified
        }
        return .guest
    }
}

public enum KYCState: String, CaseIterable {
    case new = "NEW"
    case verified = "DOCS_VERIFIED"
    case rejected = "REJECTED"
}
