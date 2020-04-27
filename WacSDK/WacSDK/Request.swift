
import Alamofire
import PromiseKit

class Request {
    
    func request(_ resource: Resource,
                 parameters: [String: Any] = [:],
                 headers: HTTPHeaders = [:]) -> Promise <Data> {
        return Promise { resolver in
            
            let method = resource.resource.method
            let url = "\(WAC().baseURL)\(resource.resource.route)"
            
            AF.request(url, method: method,
                       parameters: parameters,
                       encoding: URLEncoding(destination: .queryString),
                       headers: headers)
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        resolver.fulfill(data)
                    case .failure(let error):
                        // pass the error into the reject function, so we can check what causes the error
                        resolver.reject(error)
                    }
            }
        }
    }
}
