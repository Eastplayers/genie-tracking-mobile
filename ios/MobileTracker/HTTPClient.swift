import Foundation

/// HTTP client for sending events to the backend
class HTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    /// Send events to the backend endpoint
    /// - Parameters:
    ///   - events: Array of events to send
    ///   - endpoint: Backend endpoint URL
    ///   - apiKey: API key for authentication
    ///   - completion: Completion handler with result
    func send(
        events: [Event],
        to endpoint: String,
        apiKey: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // Validate endpoint URL
        guard let url = URL(string: endpoint) else {
            completion(.failure(HTTPClientError.invalidEndpoint))
            return
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.timeoutInterval = 30
        
        // Encode events as JSON
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let jsonData = try encoder.encode(events)
            request.httpBody = jsonData
        } catch {
            completion(.failure(HTTPClientError.serializationFailed(error)))
            return
        }
        
        // Send request
        let task = session.dataTask(with: request) { data, response, error in
            // Handle network error
            if let error = error {
                completion(.failure(HTTPClientError.networkError(error)))
                return
            }
            
            // Check HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(HTTPClientError.invalidResponse))
                return
            }
            
            // Check status code
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(HTTPClientError.httpError(statusCode: httpResponse.statusCode)))
                return
            }
            
            // Success
            completion(.success(()))
        }
        
        task.resume()
    }
}

/// Errors that can occur during HTTP operations
enum HTTPClientError: Error, Equatable {
    case invalidEndpoint
    case serializationFailed(Error)
    case networkError(Error)
    case invalidResponse
    case httpError(statusCode: Int)
    
    static func == (lhs: HTTPClientError, rhs: HTTPClientError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidEndpoint, .invalidEndpoint):
            return true
        case (.serializationFailed, .serializationFailed):
            return true
        case (.networkError, .networkError):
            return true
        case (.invalidResponse, .invalidResponse):
            return true
        case let (.httpError(lhsCode), .httpError(rhsCode)):
            return lhsCode == rhsCode
        default:
            return false
        }
    }
}
