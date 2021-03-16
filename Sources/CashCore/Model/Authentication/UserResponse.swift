
import Foundation

public struct UserResponse: Response, Codable {
    public let result: String
    public let error: CashCoreError?
    public let data: UserData
}

public struct UserData: Codable {
    public let id: String?
    public let username: String?
    public let email: String?
    public let hmac: String?
    public let roles: [UserRoles]?
}

public enum UserRoles: String, Codable {
    case guest = "wac-user"
    case verified = "verified"
}
