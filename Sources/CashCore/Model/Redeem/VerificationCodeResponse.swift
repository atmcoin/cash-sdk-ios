
import Foundation

public struct VerificationCodeResponse: Response, Codable {
    public let result: String
    public let error: CashCoreError?
    public let data: SendCodeItems?
}

public struct SendCodeItems: Codable {
    public let items: [CashSendCode]?
}

public struct CashSendCode: Codable {
    public let result: String
}
