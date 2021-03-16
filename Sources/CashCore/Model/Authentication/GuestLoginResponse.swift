
import Foundation

public struct GuestLoginResponse: Response, Codable {
    public let result: String
    public let error: CashCoreError?
    public let data: GuestLoginData
}

public struct GuestLoginData: Codable {
    public let sessionKey: String?
}
