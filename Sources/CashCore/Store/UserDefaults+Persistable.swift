
import Foundation

protocol Persistable {
    func setObject<T>(_ object: T, for key: String) throws where T: Encodable, T: Decodable
    func setObjects<T>(_ objects: [T], for key: String) throws where T: Encodable
    func getObject<T>(for key: String) throws -> T? where T: Decodable
    func getAllObjects<T>(for key: String) throws -> [T] where T: Decodable
    func updateObject<T: Equatable>(_ object: T, for key: String) throws where T : Encodable, T: Decodable
    func removeAllObjects()
}

enum PersistableError: String, LocalizedError {
    case unableToEncode
    case unableToDecode
    
    var errorDescription: String {
        switch self {
        case .unableToEncode:
            return NSLocalizedString("Unable to encode object into data", comment: "Encode Error")
        case .unableToDecode:
            return NSLocalizedString("Unable to decode object into given type", comment: "No Data Error")
        }
    }
}

extension UserDefaults: Persistable {
    
    public enum Keys: String, CaseIterable {
        case Transactions
        case Hello // Not used anymore
        case User
        case Session
    }
    
    func setObject<T>(_ object: T, for key: String) throws where T: Encodable, T: Decodable {
        do {
            var allObjects: [T] = try getAllObjects(for: key)
            allObjects.append(object)
            let data = try JSONEncoder().encode(allObjects)
            set(data, forKey: key)
        } catch {
            throw PersistableError.unableToEncode
        }
    }
    
    func setObjects<T>(_ objects: [T], for key: String) throws where T: Encodable {
        do {
            let data = try JSONEncoder().encode(objects)
            set(data, forKey: key)
        }
        catch {
            throw PersistableError.unableToEncode
        }
    }
    
    func getObject<T>(for key: String) throws -> T? where T: Decodable {
        guard let data = data(forKey: key) else {
            return nil
        }

        do {
            let object = try JSONDecoder().decode(T.self, from: data)
            return object
        } catch {
            throw PersistableError.unableToDecode
        }
    }
    
    func getAllObjects<T>(for key: String) throws -> [T] where T: Decodable {
        guard let data = value(forKey: key) as? Data else {
            return []
        }
        
        do {
            let objects = try JSONDecoder().decode([T].self, from: data)
            return objects
        } catch {
            throw PersistableError.unableToDecode
        }
    }
    
    func updateObject<T: Equatable>(_ object: T, for key: String) throws where T : Decodable, T : Encodable {
        let encoder = JSONEncoder()
        do {
            var allObjects: [T] = try getAllObjects(for: key)
            for (index, t) in allObjects.enumerated() {
                if t == object {
                    allObjects[index] = t
                }
            }
            let data = try encoder.encode(allObjects)
            set(data, forKey: key)
        } catch {
            throw PersistableError.unableToEncode
        }
    }
    
    func removeAllObjects() {
        Keys.allCases.forEach { removeObject(forKey: $0.rawValue) }
    }

}
