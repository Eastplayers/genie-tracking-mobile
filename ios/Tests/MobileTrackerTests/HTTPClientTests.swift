import XCTest
@testable import MobileTracker

class HTTPClientTests: XCTestCase {
    
    func testSendEventsWithValidEndpoint() {
        // Create a mock URLSession for testing
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let mockSession = URLSession(configuration: configuration)
        
        let client = HTTPClient(session: mockSession)
        
        // Create test event
        let context = EventContext(platform: "ios", osVersion: "17.0", appVersion: "1.0.0")
        let event = Event(
            type: "track",
            name: "Test Event",
            userId: "user123",
            traits: nil,
            properties: ["key": "value"],
            context: context,
            timestamp: "2025-11-27T10:00:00.000Z"
        )
        
        // Set up mock response
        MockURLProtocol.requestHandler = { request in
            // Verify request method
            XCTAssertEqual(request.httpMethod, "POST")
            
            // Verify headers
            XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
            XCTAssertEqual(request.value(forHTTPHeaderField: "X-API-Key"), "test-api-key")
            
            // Verify body contains event data (httpBody may be nil if using httpBodyStream)
            // The actual body verification would require more complex mocking
            
            // Return success response
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }
        
        let expectation = self.expectation(description: "HTTP request completes")
        
        client.send(events: [event], to: "https://api.example.com/events", apiKey: "test-api-key") { result in
            switch result {
            case .success:
                // Success expected
                break
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
    }
    
    func testSendEventsWithInvalidEndpoint() {
        let client = HTTPClient()
        
        let context = EventContext(platform: "ios", osVersion: "17.0", appVersion: "1.0.0")
        let event = Event(
            type: "track",
            name: "Test Event",
            userId: nil,
            traits: nil,
            properties: nil,
            context: context,
            timestamp: "2025-11-27T10:00:00.000Z"
        )
        
        let expectation = self.expectation(description: "HTTP request fails")
        
        client.send(events: [event], to: "", apiKey: "test-api-key") { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                if case HTTPClientError.invalidEndpoint = error {
                    // Expected error
                } else {
                    XCTFail("Expected invalidEndpoint error but got: \(error)")
                }
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
    }
    
    func testSendEventsWithHTTPError() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let mockSession = URLSession(configuration: configuration)
        
        let client = HTTPClient(session: mockSession)
        
        let context = EventContext(platform: "ios", osVersion: "17.0", appVersion: "1.0.0")
        let event = Event(
            type: "track",
            name: "Test Event",
            userId: nil,
            traits: nil,
            properties: nil,
            context: context,
            timestamp: "2025-11-27T10:00:00.000Z"
        )
        
        // Set up mock response with error status
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 400,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }
        
        let expectation = self.expectation(description: "HTTP request fails with 400")
        
        client.send(events: [event], to: "https://api.example.com/events", apiKey: "test-api-key") { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                if case HTTPClientError.httpError(let statusCode) = error {
                    XCTAssertEqual(statusCode, 400)
                } else {
                    XCTFail("Expected httpError but got: \(error)")
                }
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
    }
}

// Mock URLProtocol for testing
class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Handler is unavailable")
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {
        // No-op
    }
}
