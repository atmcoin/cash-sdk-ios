
import Foundation

public struct Support: Codable {
    
    public struct Category: Codable {
        public let id: String
        public let title: String
    }
    
    public struct Topic: Codable {
        public let id: String
        public let title: String
        public let content: String
        public let categoryId: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case title
            case content
            case categoryId = "category_id"
        }
    }
    
    public let categories: [Category]
    public let pages: [Topic]
    
    /// Returns an array of topic based on a category id
    /// - Parameters:
    ///     - categoryId: category string to filter by
    public func topics(for categoryId: String) -> [Topic] {
        let tops = pages.filter( { $0.categoryId == categoryId } )
        return tops
    }
    
    /// Returns a topic object based on a unique id or nil
    /// - Parameters:
    ///     - id: unique string identifying the Topic
    public func topic(for id: String) -> Topic? {
        let top = pages.filter( { $0.id == id } )
        return top.first
    }
}
