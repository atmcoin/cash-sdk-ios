
import Foundation

public struct LoginResponse: Response, Codable {
    public let result: String
    public let error: CashCoreError?
    public let data: LoginData
}

public struct LoginData: Codable {
    public let sessionKey: String?
}
