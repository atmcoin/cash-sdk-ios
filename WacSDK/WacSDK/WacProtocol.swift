
import Foundation

protocol WacProtocol {
     func createSession(_ listener: SessionCallback)
     func createCashCode(_ atmId: String, _ amount: String, _ verificationCode: String, completion: @escaping (CashCodeResponse) -> ())
     func checkCashCodeStatus(_ code: String, completion: @escaping (CashCodeStatusResponse) -> ())
     func getAtmList(completion: @escaping (AtmListResponse) -> ())
     func getAtmListByLocation(_ latitude: String, _ longitude: String, completion: @escaping (AtmListResponse) -> ())
     func sendVerificationCode(first name: String, surname last: String, phoneNumber: String, email: String, completion: @escaping (SendVerificationCodeResponse) -> ())
}
