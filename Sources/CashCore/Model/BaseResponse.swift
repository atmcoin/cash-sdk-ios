
import Foundation

public protocol Response {
    var result: String { get }
    var error: CashCoreError? { get }
}

public struct BaseResponse: Response, Codable {
    public let result: String
    public let error: CashCoreError?
    public let data: BaseItems?
}

public struct BaseItems: Codable {
    public let items: [BaseItem]?
}

public struct BaseItem: Codable {
    public let result: String?
}

enum CodingKeys: String, CodingKey {
    case result
}
