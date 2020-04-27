
import Foundation

public struct WacError: Codable {
    public let code: String
    public let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code
        case message = "server_message"
    }
}
