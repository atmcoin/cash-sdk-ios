
import Foundation

extension UserDefaults {
    
    func setTransaction(_ object: CoreTransaction) throws {
        try setObject(object, for: Keys.Transactions.rawValue)
    }
    
    func setTransactions(_ objects: [CoreTransaction]) throws {
        try setObjects(objects, for: Keys.Transactions.rawValue)
    }
    
    func getTransaction() throws -> CoreTransaction? {
        return try getObject(for: Keys.Transactions.rawValue)
    }
    
    func updateTransaction(_ object: CoreTransaction, for key: String) throws {
        try updateObject(object, for: Keys.Transactions.rawValue)
    }
     
    func getAllTransactions() throws -> [CoreTransaction] {
        let oldData = value(forKey: Keys.Hello.rawValue) as? Data
        if oldData == nil {
            return try getAllObjects(for: Keys.Transactions.rawValue)
        } else {
            return migrateTransactions()
        }
    }
    
    func convertTransaction(_ transaction: WACTransaction) -> CoreTransaction {
        var migratedTransaction = CoreTransaction(status: transaction.status, atm: transaction.atm, code: transaction.code)
        migratedTransaction.timestamp = transaction.timestamp
        migratedTransaction.pCode = transaction.pCode
        return migratedTransaction
    }
    
    func migrateTransactions() -> [CoreTransaction]  {
        guard let data = value(forKey: Keys.Hello.rawValue) as? Data else { return [] }
        let decoder = JSONDecoder()
        do {
            let objects = try decoder.decode([WACTransaction].self, from: data)
            
            var newObjects: [CoreTransaction] = []
            for transaction in objects {
                let newTransaction = convertTransaction(transaction)
                newObjects.append(newTransaction)
            }
            if newObjects.count > 0 {
                removeObject(forKey: Keys.Hello.rawValue)
                try setObjects(newObjects, for: Keys.Transactions.rawValue)
            }
            return newObjects
        } catch {
            return []
        }
    }
    
}
