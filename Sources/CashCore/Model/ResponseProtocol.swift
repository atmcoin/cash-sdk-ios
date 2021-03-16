
import Foundation

public protocol Response {
    var result: String { get }
    var error: CashCoreError? { get }
}

private struct ResponseStruct : Response {
    let result: String
    let error: CashCoreError?
    
    init() {
        result = ""
        error = nil
    }
}
