
import Foundation

/*
 {
    "result": "ok",
    "error": null,
    "data": {}
 }
 */

public struct AtmListResponse: Response, Codable {
    public let result: String
    public let error: CashSDKError?
    public let data: AtmItems?
}

public struct AtmItems: Codable {
    public let items: [AtmMachine]
}

/*
 {
     "atm_id": "5004",
     "address_desc": "Target Lake Park",
     "address_street": "500 N Congress Ave",
     "address_detail": null,
     "address_city": "Lake Park",
     "address_state": "FL",
     "address_zip": "33403",
     "loc_lon": "-80.0830290",
     "loc_lat": "26.8053350",
     "atm_desc": "test_FLL",
     "atm_fees": "0.00",
     "atm_min": "20.00",
     "atm_max": "600.00",
     "atm_bills": "20.00",
     "atm_currency": "USD",
     "atm_red": "1"
 }
 */
public struct AtmMachine: Codable {
    public let atmId: Int
    public let addressDesc: String?
    public let detail: String?
    public let street: String?
    public let city: String? = ""
    public let state: String? = ""
    public let zip: String? = ""
    public let longitude: Double
    public let latitude: Double
    public let desc: String?
    public let fees: String?
    public let min: Float
    public let max: Float
    public let bills: Float
    public let currency: String?
    public let redemption: Int

    enum CodingKeys: String, CodingKey {
        case atmId = "atm_id"
        case addressDesc = "address_desc"
        case detail = "address_detail"
        case street = "address_street"
        case city = "address_city"
        case state = "address_state"
        case zip = "address_zip"
        case longitude = "loc_lon"
        case latitude = "loc_lat"
        case desc = "atm_desc"
        case fees = "atm_fees"
        case min = "atm_min"
        case max = "atm_max"
        case bills = "atm_bills"
        case currency = "atm_currency"
        case redemption = "atm_red"
    }
    
    public func isRedeemable() -> Bool {
        return redemption != 0
    }
}
