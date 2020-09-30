
public enum HTTPMethod: String {
    case GET
    case POST
}

public enum Resource {
    // Redeem
    case checkCodeStatus(String)
    case createCode
    case getAtmList
    case getAtmListByLocation(String, String)
    case isSessionValid
    case login
    case sendVerificationCode
    
    public var method: HTTPMethod {
        switch self {
        case .checkCodeStatus, .getAtmList, .getAtmListByLocation, .isSessionValid:
            return HTTPMethod.GET
        case .createCode, .login, .sendVerificationCode:
            return HTTPMethod.POST
        }
    }
    
    public var path: String {
        switch self {
        case .checkCodeStatus(let pcode):
            return "/atm/wac/pcode/\(pcode)"
        case .createCode:
            return "/atm/wac/pcode"
        case .getAtmList:
            return "/atm/wac/atm/list"
        case .getAtmListByLocation(let lat, let long):
            return "/atm/wac/atm/near/latlon/\(lat)/\(long)"
        case .isSessionValid:
            return "/atm/auth/user"
        case .login:
            return "/atm/wac/guest/login"
        case .sendVerificationCode:
            return "/atm/wac/pcode/verify"
        }
    }
}
