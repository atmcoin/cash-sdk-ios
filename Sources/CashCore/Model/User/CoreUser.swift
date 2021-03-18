import Foundation

public struct CoreUser: Codable, Equatable {
    public var firstName: String
    public var lastName: String
    public var phoneNumber: String
    public var email: String
    public var sessionKey: String
    
    init(firstName name: String, lastName surname: String, phone number: String, session key: String? = "", email: String? = "") {
        self.firstName = name
        self.lastName = surname
        self.phoneNumber = number
        self.email = email!
        self.sessionKey = key!
    }
    
    public mutating func update(session key: String) {
        sessionKey = key
    }
    
    public func toDictionary() -> [AnyHashable: String] {
        var dict: [AnyHashable: String] = [:]
        dict[kPhoneNumber] = self.phoneNumber
        dict[kLastName] = self.lastName
        dict[kFirstName] = self.firstName
        dict[kEmail] = self.email
        dict[kSessionKey] = self.sessionKey
        
        return dict
    }
    
    public static func user(from object: [AnyHashable: String]) -> CoreUser {
        let phoneNumber = object[kPhoneNumber]
        let lastName = object[kLastName]
        let firstName = object[kFirstName]
        let email = object[kEmail]
        let sessionKey = object[kSessionKey]
        
        return CoreUser(firstName: firstName!, lastName: lastName!, phone: phoneNumber!, session: sessionKey, email: email)
    }
    
    public static func == (lhs: CoreUser, rhs: CoreUser) -> Bool {
        return lhs.phoneNumber == rhs.phoneNumber
    }
}
