
import Foundation

public struct LoginResponse: Codable {
    public let result: String
    public let error: String?
    public let data: LoginData
}

public struct LoginData: Codable {
    public let sessionKey: String?
}
