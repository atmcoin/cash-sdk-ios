
import Foundation

class Request {
    private var url: URL
    
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
                 body: [String: String] = [:],
                 headers: [String: String] = [:],
                 completion: @escaping (Data?, Error?) -> ()) {
        
        let components = URLComponents(url: self.url, resolvingAgainstBaseURL: false)
        guard var urlComponents = components else { return }
        urlComponents.path = resource.resource.route
        if (query.count > 0) {
            urlComponents.queryItems = queryItems(query)
        }
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = resource.resource.method.rawValue
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let httpMethod = resource.resource.method
        
        if (httpMethod == .post) {
            let postData = try? JSONSerialization.data(withJSONObject: body)
            request.httpBody = postData
        }
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            DispatchQueue.main.async {
                let str = String(decoding: data!, as: UTF8.self)
                print(str)
                completion(data, error)
            }
            
        })
        
        dataTask.resume()
    }
}

