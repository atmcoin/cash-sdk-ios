
import Foundation

public struct CodeStatusResponse: Codable {
    public let result: String
    public let error: WacError?
    public let data: CodeStatusItems?
}

public struct CodeStatusItems: Codable {
    public let items: [CashStatus]
}

public struct CashStatus: Codable {
    public let code: String?
    public let status: String?
    public let address: String?
    public let usdAmount: String?
    public let btcAmount: String?
    public let unitPrice: String?
    public let expiration: String?
    public let atmId: String?
    public let description: String?
    public let latitude: String?
    public let longitude: String?
    
    enum CodingKeys: String, CodingKey {
        case code = "pcode"
        case status
        case address
        case usdAmount = "usd_amount"
        case btcAmount = "btc_amount"
        case unitPrice = "btc_whole_unit_price"
        case expiration
        case atmId = "atm_id"
        case description = "loc_description"
        case latitude = "loc_lat"
        case longitude = "loc_lon"
    }
    
    func getCodeStatus() -> CodeStatus? {
        for code in CodeStatus.allCases {
            if (code.rawValue == status) {
                return code
            }
        }
        return nil
    }
}

enum CodeStatus: String, CaseIterable {
    case NEW_CODE = "A"
    case FUNDED_NOT_CONFIRMED = "W"
    case FUNDED = "V"
    case USED = "U"
    case CANCELLED = "C"
}
