

import Foundation

public struct CashCodeResponse: Response, Codable {
    public let result: String
    public let error: CashCoreError?
    public let data: CashCodeItems?
}

public struct CashCodeItems: Codable {
    public let items: [CashCode]?
}

/*
 {
     "secure_code": "ngupunxokbpkiegeqofj",
     "address": "2N3bFMDuRtfCkCfX5w5fBevCy7cRScjpoGL",
     "usd_amount": "20",
     "btc_amount": "0.00259302",
     "btc_whole_unit_price": "7713"
 }
 */
public struct CashCode: Codable {
    public var secureCode: String?
    public let address: String?
    public let usdAmount: String?
    public let btcAmount: String?
    public let unitPrice: String?
    
    enum CodingKeys: String, CodingKey {
        case secureCode = "secure_code"
        case address
        case usdAmount = "usd_amount"
        case btcAmount = "btc_amount"
        case unitPrice = "btc_whole_unit_price"
    }
}
