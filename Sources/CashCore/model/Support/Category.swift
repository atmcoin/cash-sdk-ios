
import Foundation

public struct Category: Codable {
    public let id: String
    public let title: String
    public let topics: [Topic]
}
