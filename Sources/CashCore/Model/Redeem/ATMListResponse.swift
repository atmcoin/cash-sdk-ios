
import Foundation

public struct AtmListResponse: Response, Codable {
    public let result: String
    public let error: CashCoreError?
    public let data: AtmItems?
}

public struct AtmItems: Codable {
    public let items: [AtmMachine]
}

/*
 {
     "atm_id": 8,
     "address_desc": "Dragon Mart",
     "address_street": "3201 N Lamar Blvd",
     "address_detail": null,
     "address_city": "Austin",
     "address_state": "TX",
     "address_zip": "78705",
     "loc_lon": -97.7473528,
     "loc_lat": 30.3015207,
     "atm_desc": "Dragon Mart",
     "atm_min": 20.0,
     "atm_max": 300.0,
     "atm_bills": 20.0,
     "atm_currency": "USD",
     "atm_pur": 1,
     "atm_red": 0
 }
 */
public struct AtmMachine: Codable {
    public let atmId: String?
    public let addressDesc: String?
    public let detail: String?
    public let street: String?
    public let city: String?
    public let state: String?
    public let zip: String?
    public let longitude: String?
    public let latitude: String?
    public let desc: String?
    public let fees: String?
    public let min: String?
    public let max: String?
    public let bills: String?
    public let currency: String?
    public let redemption: String?
    public let purchase: String?

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
        case purchase = "atm_pur"
    }
}
