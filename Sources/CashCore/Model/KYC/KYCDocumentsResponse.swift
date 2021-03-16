
import Foundation

public struct KYCDocumentsResponse: Response, Codable {
    public let result: String
    public let error: CashCoreError?
    public let data: KYCDocumentItems?
}

public struct KYCDocumentItems: Codable {
    public let items: [KYCDocument]
}

public struct KYCDocument: Codable {
    public let type: String?
    public let status: String?
    public let rejectionReason: String?
    public let description: String?
    public let uploadDate: String?

    enum CodingKeys: String, CodingKey {
        case type
        case status
        case rejectionReason = "rejection_reason"
        case description
        case uploadDate = "upload_date"
    }
    
    public func getDocumentStatus() -> KYCDocumentStatus {
        for stat in KYCDocumentStatus.allCases {
            if stat.rawValue == status {
                return stat
            }
        }
        return .unknown
    }
}

public enum KYCDocumentStatus: String, CaseIterable {
    case unknown
    case pending = "PENDING"
    case accepted = "ACCEPTED"
    case rejected = "REJECTED"
}

public enum KYCDocumentType: String, CaseIterable {
    case front = "ID_FRONT"
    case back = "ID_BACK"
    case selfie = "SELFIE"
}
