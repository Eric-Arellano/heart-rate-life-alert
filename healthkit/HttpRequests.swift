import Foundation

class HTTPRequests {
    
    static func postJSON(json: [String: Any], suffix: String) {
        let request = setupRequest(json: json, suffix: suffix)
        sendRequest(request: request)
    }
    
    private static func setupRequest(json: [String: Any], suffix: String) -> URLRequest {
        var request = URLRequest(url: URL(string: "http://192.168.43.94:5000/"+suffix)!)
        request.httpMethod = "POST"
        let postedJSON = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = postedJSON
        return request
    }
    
    private static func sendRequest(request: URLRequest) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            self.checkNetworkingErrors(data: data!, error: error!)
            self.checkHTTPErrors(response: response!)
            print(self.getResponseString(data: data!))
        }
        task.resume()
    }
    
    private static func checkNetworkingErrors(data: Data?, error: Error?) {
        guard let _ = data, error == nil else {
            print("error=\(error)")
            return
        }
    }
    
    private static func checkHTTPErrors(response: URLResponse) {
        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
            print("statusCode should be 200, but is \(httpStatus.statusCode)")
            print("response = \(response)")
        }
    }
    
    private static func getResponseString(data: Data) -> String {
        return String(data: data, encoding: .utf8)!
    }
    
}
