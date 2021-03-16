
import Foundation

// TODO:
//   throw exceptions

open class CoreTransactionManager {
    
    static let shared: CoreTransactionManager = {
        let instance = CoreTransactionManager()
        return instance
    }()
    
    /**
     Polling interval in seconds. Defaults to 60 seconds
     */
    public var pollingInterval: Double = 60
    public var pendingExpiryInterval: Double = 15*60
    private var timer: Timer?
    
    private init() {}
    
    /**
     Polls the status of each transaction that has not been cancelled or withdrawn
     */
    public class func startPolling() {
        pollTransactionUpdates()
    }
    
    /**
     Stops polling
     */
    public class func stopPolling() {
        CoreTransactionManager.shared.timer?.invalidate()
    }
    
    /**
     Stores a transaction
     */
    public class func store(_ transaction: CoreTransaction) {
        do {
            var allObjects = try UserDefaults.standard.getAllTransactions()
            for trans in allObjects {
                if (transaction == trans) {
                    // throw exception
                }
                else {
                    allObjects.append(transaction)
                    try UserDefaults.standard.setTransactions(allObjects)
                    return
                }
            }
            if allObjects.count == 0 {
                try UserDefaults.standard.setTransaction(transaction)
            }
        }
        catch {}
    }
    
    /**
     Gets all transactions stored in local
     */
    public class func getTransactions() -> [CoreTransaction] {
        do {
            return try UserDefaults.standard.getAllTransactions()
        }
        catch {}
        return []
    }
    
    /**
     Gets a transaction based on the creation timestamp
     
     - returns:
     A transaction matching the timestamp or nil
     
     - parameters:
        - for: The timestamp of the transaction to query
     
     Lookup of transactions by timestamp will be deprecated to use a unique identifier. Timestamps will not be unique when daylights savings time end, for example.
     */
    @available(*, deprecated, message: "Lookups by timestamp will not be available in the future")
    public class func getTransaction(for timestamp: Double) -> CoreTransaction? {
        do {
            let allObjects = try UserDefaults.standard.getAllTransactions()
            for transaction in allObjects {
                if (transaction.timestamp == timestamp) {
                    return transaction
                }
            }
        }
        catch {}
        return nil
    }
    
    /**
     Gets a transaction based on the address
     
     - returns:
     A transaction, from store, matching the address given or nil
     
     - parameters:
        - for: An address for the transaction to be queried
     */
    public class func getTransaction(for address: String) -> CoreTransaction? {
        do {
            let allObjects = try UserDefaults.standard.getAllTransactions()
            for transaction in allObjects {
                if (transaction.code?.address == address) {
                    return transaction
                }
            }
        }
        catch {}
        return nil
    }
    
    /**
     Removes a transaction based on timestamp
     
     - parameters:
        - for: The timestamp of the transaction to query
     
     Removal of transactions by timestamp will be deprecated to use a unique identifier. Timestamps will not be unique when daylights savings time end, for example.
     */
    @available(*, deprecated, message: "Removal by timestamp will not be available in the future")
    public class func removeTransaction(for timestamp: Double) {
        do {
            var allObjects = try UserDefaults.standard.getAllTransactions()
            allObjects = allObjects.filter { $0.timestamp !=  timestamp}
            try UserDefaults.standard.setTransactions(allObjects)
            NotificationCenter.default.post(name: .CoreTransactionDidChange, object: nil)
        }
        catch {}
    }
    
    /**
    Removes a transaction
    
    - parameters:
       - _: The transaction to remove
     
     A notification of the removal is not sent as it may have conflicts with UI.
     Use getTransactions() to get the updated array of transactions.
    */
    public class func remove(_ transaction: CoreTransaction) {
        do {
            var allObjects = try UserDefaults.standard.getAllTransactions()
            allObjects = allObjects.filter { $0.id !=  transaction.id}
            try UserDefaults.standard.setTransactions(allObjects)
        }
        catch {}
    }
    
    /**
     Updates a transaction based on the uniqueness of the address
     
     - parameters:
        - _: The transaction to be updated
     */
    public class func updateTransaction(_ object: CoreTransaction) {
        do {
            var allObjects = try UserDefaults.standard.getAllTransactions()
            if let idx = allObjects.firstIndex(where: { $0.code?.address == object.code?.address }) {
                allObjects[idx] = object
                try UserDefaults.standard.setTransactions(allObjects)
                NotificationCenter.default.post(name: .CoreTransactionDidChange, object: object)
            }
        }
        catch{}
    }
    
    /**
    Updates the status of a transaction based on the timestamp
    
    - parameters:
        - status: the new status for the transaction being updated
        - with: the timestamp used to query the transaction
    
    Updating a transaction by timestamp will be deprecated to use a unique identifier. Timestamps will not be unique when daylights savings time end, for example.
    */
    @available(*, deprecated, message: "Update by timestamp will not be available in the future")
    public class func updateTransaction(status: CoreTransactionStatus, with timestamp: Double) {
        if var transaction = getTransaction(for: timestamp) {
            transaction.status = status
            updateTransaction(transaction)
        }
    }
    
    /**
    Updates the status of a transaction based on the address
    
    - parameters:
        - status: the new status for the transaction being updated
        - address: the address used to query the transaction
    */
    public class func updateTransaction(status: CoreTransactionStatus, address: String, code: String? = nil, pCode: String? = nil) {
        if var transaction = getTransaction(for: address) {
            transaction.status = status
            if let code = code, !code.isEmpty {
                transaction.code?.secureCode = code
            }
            if let pcode = pCode, !pcode.isEmpty {
                transaction.pCode = pCode
            }
            updateTransaction(transaction)
        }
    }
    
    public class func pollImmediately() {
        determineTransactionAction()
    }
    
    /**
     Polls for a particular transaction status
     
     - parameters:
        - _: The transaction to be polled for status
     */
    private class func poll(_ transaction: CoreTransaction) {
        guard let code = transaction.code?.secureCode, !code.isEmpty else { return }
        
        CoreSessionManager.shared.client?.checkCashCodeStatus(code, result: { (result) in
            switch result {
            case .success(let response):
                let cashCode = (response.data?.items.first)! as CashStatus
                let codeStatus = cashCode.getCodeStatus()!
                let transactionStatus = CoreTransactionStatus.transactionStatus(from: codeStatus)
                let pCode = transactionStatus == .Funded ? cashCode.code : nil
                updateTransaction(status: transactionStatus, address: cashCode.address!, pCode: pCode)
                
                NotificationCenter.default.post(name: .CoreTransactionDidChange, object: transaction)
                break
            case .failure(_):
                break
            }
        })
    }
    
    /**
     Determines an action for each transaction. Transactions can be:
     - moved to different states according to the server response.
     - moved to cancel if it has been pending for x amount of time. Server driven but defaulted to 15 minutes
     */
    private class func determineTransactionAction() {
        for transaction in getTransactions() {
            switch transaction.status {
            case .VerifyPending, .SendPending:
                CoreTransactionManager.cancelPending(transaction)
            case .Awaiting, .FundedNotConfirmed, .Funded, .Withdrawn, .Cancelled, .Error:
                CoreTransactionManager.poll(transaction)
            }
        }
    }
    
    /**
     Removes a pending transaction
     
     - parameters:
        - _: the transaction to be removed
     */
    private class func removePending(_ transaction: CoreTransaction) {
        if (Date().timeIntervalSince1970 - transaction.timestamp >= CoreTransactionManager.shared.pendingExpiryInterval) {
            removeTransaction(for: transaction.timestamp)
        }
    }
    
    /**
     Cancels a pending transaction
     
     - parameters:
        - _: the transaction to be cancelled
     */
    private class func cancelPending(_ transaction: CoreTransaction) {
        if (Date().timeIntervalSince1970 - transaction.timestamp >= CoreTransactionManager.shared.pendingExpiryInterval) {
            updateTransaction(status: .Cancelled, with: transaction.timestamp)
        }
    }
    
    /**
     Polls a status update from the server every x amount of time. Defaulted to 60 seconds. Configurable via *pollingInterval*
     */
    private class func pollTransactionUpdates() {
        CoreTransactionManager.shared.timer = Timer.scheduledTimer(withTimeInterval: CoreTransactionManager.shared.pollingInterval, repeats: true, block: { (timer) in
            determineTransactionAction()
        })
    }
}

extension Notification.Name {

    /**
     Notifies when a change has ocurred for a transaction. Removing a transaction is also considered a change.
     */
    public static let CoreTransactionDidChange = Notification.Name(rawValue: "CoreTransactionDidChange")
}
