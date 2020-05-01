
import Foundation

public struct AtmListResponse: Codable {
    public let result: String
    public let error: WacError?
    public let data: AtmItems?
}

public struct AtmItems: Codable {
    public let items: [AtmMachine]
}

public struct AtmMachine: Codable {
    public let atmId: String?
    public let addressDesc: String?
    public let detail: String?
    public let city: String?
    public let zip: String?
    public let longitude: String?
    public let latitude: String?
    public let desc: String?
    public let fees: String?
    public let min: String?
    public let max: String?
    public let bills: String?
    public let currency: String?

    enum CodingKeys: String, CodingKey {
        case atmId = "atm_id"
        case addressDesc = "address_desc"
        case detail = "address_detail"
        case city = "address_city"
        case zip = "address_zip"
        case longitude = "loc_lon"
        case latitude = "loc_lat"
        case desc = "atm_desc"
        case fees = "atm_fees"
        case min = "atm_min"
        case max = "atm_max"
        case bills = "atm_bills"
        case currency = "atm_currency"
    }
}
