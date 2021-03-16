
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
    }
    
    public func getKYCDocumentsStatus() -> KYCDocumentsStatus? {
        for code in KYCDocumentsStatus.allCases {
            if (code.rawValue == status) {
                return code
            }
        }
        return nil
    }
}

public enum KYCDocumentsStatus: String, CaseIterable {
    case new = "NEW"
    case verified = "DOCS_VERIFIED"
    case rejected = "REJECTED"
}
