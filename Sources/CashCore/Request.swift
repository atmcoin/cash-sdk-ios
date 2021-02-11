
import Foundation

class Request {
    private var url: URL
    private let session = URLSession(configuration: URLSessionConfiguration.default)
    
    init(url: String) {
        self.url = URL(string: url)!
    }
    
    func queryItems(_ from: [String: String]) -> [URLQueryItem]? {
       return from.map {
            URLQueryItem(name: $0, value: $1)
        }
    }
    
    func request(_ resource: Resource,
                 query: [String: String] = [:],
                 body: [String: Any] = [:],
                 headers: [String: String] = [:],
                 completion: @escaping (Result<Data, CashCoreError>) -> Void) {
        
        // URL will be built from components.
        // First, add the URL
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            completion(.failure(CashCoreError.init(code: "\(CashCoreErrorCode.invalidEndPoint.rawValue)",
                message: "URLComponents Failure: Invalid URL End Point")))
            return
        }
        urlComponents.path = resource.path
    
        // If query items, build the query string.
        if (query.count > 0) {
            urlComponents.queryItems = queryItems(query)
        }
        
        // Add HTTP headers
        guard let url = urlComponents.url else {
            completion(.failure(CashCoreError.init(code: "\(CashCoreErrorCode.invalidEndPoint.rawValue)",
                message: "URLComponents Failure: A URL could not be created. Possible query string error")))
            return
        }
        var request = URLRequest(url: url)
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Specify the HTTP method
        let httpMethod = resource.method
        request.httpMethod = httpMethod.rawValue
    
        // If POST, add a body
        if (httpMethod == HTTPMethod.POST) {
            let postData = try? JSONSerialization.data(withJSONObject: body)
            request.httpBody = postData
        }
        
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    let err = CashCoreError(code: String((error as NSError).code), message: error.localizedDescription)
                    completion(.failure(err))
                    return
                }
                guard let _ = response, let data = data else {
                    let error = CashCoreError(code: "\(CashCoreErrorCode.corruptedResponse.rawValue)",
                        message: "Response Corrupted: There was an error with the response or data in the response of \(String(describing: request.url))")
                    completion(.failure(error))
                    return
                }
                completion(.success(data))
            }
        })
        
        dataTask.resume()
    }
}

