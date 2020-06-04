
import Foundation

protocol Response {
    var result: String { get }
    var error: WacError? { get }
}

private struct ResponseStruct : Response {
    let result: String
    let error: WacError?
    
    init() {
        result = ""
        error = nil
    }
}
