
import Foundation

protocol EndPoints {
    
    /// Creates a session key to be passed on the header of other endpoint requests.
    /// The session key is not authorization key and does not posses any encrypted
    /// user information.
    /// - Parameters:
    ///   - listener: the class(es) that need to interact with the session key.
    /// - Note:
    ///   This session key does not need to be persisted. This session key is just needed
    ///   for interaction with the server. It is weird how the key acts; instead of providing
    ///   an authorization bearer for a user, any session key created can be used to invoke
    ///   API calls to the server
    func createGuestSession(_ listener: SessionCallback)
    
    /// Creates a secure cash code that identifies the transaction with the server.
    /// - Parameters:
    ///   - atmId: atm's identifier
    ///   - amount: amount of crypto currency to be redeemed
    ///   - verificationCode: the sms or email code to verify the transaction
    ///   - result: callback with the data object or error from the response
    func createCashCode(_ atmId: String, _ amount: String, _ verificationCode: String, result: @escaping (Result<CashCodeResponse, CashCoreError>) -> Void)
    
    
    /// Checks the status of a transaction
    /// - Parameters:
    ///   - code: the code used as unique identifier to check the status
    ///   - result: callback with the data object or error from the response
    func checkCashCodeStatus(_ code: String, result: @escaping (Result<CashCodeStatusResponse, CashCoreError>) -> Void)
    
    
    /// Gets a list of all available ATMs
    /// - Parameter result: callback with the data object or error from the response
    func getAtmList(result: @escaping (Result<AtmListResponse, CashCoreError>) -> Void)
    
    
    /// Gets a list of ATMs based on coordinates
    /// - Parameters:
    ///   - latitude: the latitude value of the coordinate to lookup
    ///   - longitude: the longitude value of the coordinate to lookup
    ///   - result: callback with the data object or error from the response
    func getAtmListByLocation(_ latitude: String, _ longitude: String, result: @escaping (Result<AtmListResponse, CashCoreError>) -> Void)
    
    
    /// Validates a session key
    /// - Parameters:
    ///   - completion: the block to be executed upon response
    func isSessionValid(completion: @escaping ((Bool) -> ()))
    
    /// Sends a SMS or eMail verification code
    /// - Parameters:
    ///   - name: the first name of the user initiating the transaction
    ///   - last: the last name of the user initiating the transaction
    ///   - phoneNumber: the phone number of the user initiating the transaction where the code may be sent
    ///   - email: the email of the user initiating the transaction where the code may be sent
    ///   - result: callback with the data object or error from the response
    func sendVerificationCode(first name: String, surname last: String, phoneNumber: String, email: String, result: @escaping (Result<VerificationCodeResponse, CashCoreError>) -> Void)
    
    /// Validates a session key
    /// - Parameters:
    ///   - completion: the block to be executed upon response
    func login(phone number: String, result: @escaping(Result<Response, CashCoreError>) -> Void)
    
    /// Validates a session key
    /// - Parameters:
    ///   - completion: the block to be executed upon response
    func loginConfirmation(verification code: String, result: @escaping(Result<Response, CashCoreError>) -> Void)
    
    /// Validates a session key
    /// - Parameters:
    ///   - completion: the block to be executed upon response
    func register(first name: String, surname last: String, phone number: String, result: @escaping(Result<Response, CashCoreError>) -> Void)
    
    /// Validates a session key
    /// - Parameters:
    ///   - completion: the block to be executed upon response
    func getKYCStatus(result: @escaping(Result<KYCStatusResponse, CashCoreError>) -> Void)
}
