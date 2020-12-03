
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
            return "/wac/wac/pcode/\(pcode)"
        case .createCode:
            return "/wac/wac/pcode"
        case .getAtmList:
            return "/wac/wac/atm/list"
        case .getAtmListByLocation(let lat, let long):
            return "/wac/wac/atm/near/latlon/\(lat)/\(long)"
        case .isSessionValid:
            return "/wac/auth/user"
        case .login:
            return "/wac/wac/guest/login"
        case .sendVerificationCode:
            return "/wac/wac/pcode/verify"
        }
    }
}
