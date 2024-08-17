//
//  MockURLSession.swift
//  WeatherAppTests
//
//  Created by Sonika Patel on 16/08/24.
//
import XCTest

// Mock URLSession class for unit testing
class MockURLSession: URLSession {
    var data: Data?
    var error: Error?
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        // Return a mock data task that immediately calls the completion handler
        return MockURLSessionDataTask {
            completionHandler(self.data, nil, self.error)
        }
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    private let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    override func resume() {
        closure()
    }
}
