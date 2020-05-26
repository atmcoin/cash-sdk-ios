
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

public enum Resource {
    case checkCodeStatus(String)
    case createCode
    case getAtmList
    case getAtmListByLocation(String, String)
    case login
    case sendVerificationCode
    
    public var resource: (method: HTTPMethod, route: String) {
        switch self {
        case .checkCodeStatus(let pcode):
            return (.get, "/atm/wac/pcode/\(pcode)")
        case .createCode:
            return (.post, "/atm/wac/pcode")
        case .getAtmList:
            return (.get, "/atm/wac/atm/list")
        case .getAtmListByLocation(let lat, let long):
            return (.get, "/atm/wac/atm/near/latlon/\(lat)/\(long)")
        case .login:
            return (.post, "/atm/wac/guest/login")
        case .sendVerificationCode:
            return (.post, "/atm/wac/pcode/verify")
        }
    }
}
