
import Foundation

extension UserDefaults {
    
    public func setUser(_ user: CoreUser) throws {
        try setObject(user, for: Keys.User.rawValue)
    }
    
    public func getUser<CoreUser>() throws -> CoreUser? where CoreUser: Decodable {
        return try getObject(for: Keys.User.rawValue)
    }
    
}
