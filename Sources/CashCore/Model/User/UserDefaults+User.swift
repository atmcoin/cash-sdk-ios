
import Foundation

extension UserDefaults {
    
    func setUser(_ user: CoreUser) throws {
        try setObject(user, for: Keys.User.rawValue)
    }
    
    func getUser<CoreUser>() throws -> CoreUser? where CoreUser: Decodable {
        return try getObject(for: Keys.User.rawValue)
    }
    
}
