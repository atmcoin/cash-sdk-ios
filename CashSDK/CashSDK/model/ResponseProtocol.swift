
import Foundation

protocol Response {
    var result: String { get }
    var error: CashSDKError? { get }
}

private struct ResponseStruct : Response {
    let result: String
    let error: CashSDKError?
    
    init() {
        result = ""
        error = nil
    }
}
