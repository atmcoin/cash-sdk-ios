
public enum HTTPMethod: String {
    case GET
    case POST
}

protocol Resource {
    /// Gets the HTTP Method for the resource
    var method: HTTPMethod { get }
    
    /// Gets the url path for the resource
    var path: String { get }
}

public enum Redeem: Resource {
    case checkCodeStatus(String)
    case createCode
    case atmList
    case atmListByLocation(String, String)
    case verifyCode
    
    public var method: HTTPMethod {
        switch self {
        case .createCode, .verifyCode:
            return HTTPMethod.POST
        default:
            return HTTPMethod.GET
        }
    }
    
    public var path: String {
        switch self {
        case .checkCodeStatus(let pcode):
            return "/wac/wac/pcode/\(pcode)"
        case .createCode:
            return "/wac/wac/pcode"
        case .atmList:
            return "/wac/wac/atm/list"
        case .atmListByLocation(let lat, let long):
            return "/wac/wac/atm/near/latlon/\(lat)/\(long)"
        case .verifyCode:
            return "/wac/wac/pcode/verify"
        }
    }
}

// MARK: Know Your Customer
public enum KYC: Resource {
    case register
    case status
    case documents
    
    public var method: HTTPMethod {
        switch self {
        case .register:
            return HTTPMethod.POST
        case .status, .documents:
            return HTTPMethod.GET
        }
    }
    
    public var path: String {
        switch self {
        case .register:
            return "/wac/wac/register"
        case .status:
            return "/wac/wac/kyc/status"
        case .documents:
            return "/wac/wac/kyc/documents"
        }
    }
}

// MARK: Authentication
public enum Authentication: Resource {
    case guestLogin
    case login
    case loginConfirmation
    case logout
    case user
    
    public var method: HTTPMethod {
        switch self {
        case .user, .logout:
            return HTTPMethod.GET
        case .login, .loginConfirmation, .guestLogin:
            return HTTPMethod.POST
        }
    }
    
    public var path: String {
        switch self {
        case .guestLogin:
            return "/wac/wac/guest/login"
        case .login:
            return "/wac/wac/login"
        case .loginConfirmation:
            return "/wac/wac/login/confirm"
        case .user:
            return "/wac/auth/user"
        case .logout:
            return "/wac/wac/auth/logout"
        }
    }
}
