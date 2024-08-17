//
//  WeatherManagerTests.swift
//  WeatherAppTests
//
//  Created by Sonika Patel on 16/08/24.
//

import XCTest
@testable import WeatherApp

class WeatherManagerTests: XCTestCase {
    var mockSession: MockURLSession!
    var weatherManager: WeatherManager!
    
    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        weatherManager = WeatherManager(session: mockSession)
    }
    
    override func tearDown() {
        mockSession = nil
        weatherManager = nil
        super.tearDown()
    }
    
    func testFetchWeather_withValidData_shouldReturnWeatherModel() {
        // Arrange
        guard let path = Bundle(for: type(of: self)).path(forResource: "weather", ofType: "json") else {
            XCTFail("Missing file: weather.json")
            return
        }
        let jsonData = try! Data(contentsOf: URL(fileURLWithPath: path))
        mockSession.data = jsonData
        
        let expectation = self.expectation(description: "Fetch weather")
        
        // Act
        weatherManager.fetchWeather(cityName: "Austin") { result in
            // Assert
            switch result {
            case .success(let weather):
                XCTAssertEqual(weather.cityName, "Austin")
                XCTAssertEqual(weather.temperature, 58.05)
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success, but got failure")
            }
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
