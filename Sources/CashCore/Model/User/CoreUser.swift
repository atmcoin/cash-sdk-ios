import Foundation

public struct CoreUser: Codable {
    var firstName: String
    var lastName: String
    var phoneNumber: String
    var sessionKey: String
    
    init(firstName name: String, lastName surname: String, phone number: String, session key: String) {
        self.firstName = name
        self.lastName = surname
        self.phoneNumber = number
        self.sessionKey = key
    }
}
