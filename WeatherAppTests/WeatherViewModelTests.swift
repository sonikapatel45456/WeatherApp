//
//  WeatherViewModelTests.swift
//  WeatherAppTests
//
//  Created by Sonika Patel on 16/08/24.
//

import XCTest
import CoreLocation
@testable import WeatherApp

class WeatherViewModelTests: XCTestCase {
    
    var viewModel: WeatherViewModel!
    var mockWeatherManager: MockWeatherManager!
    var mockLocationManager: MockCLLocationManager!
    var mockDelegate: MockWeatherViewModelDelegate!
    
    override func setUp() {
        super.setUp()
        mockWeatherManager = MockWeatherManager()
        mockLocationManager = MockCLLocationManager()
        mockDelegate = MockWeatherViewModelDelegate()
        viewModel = WeatherViewModel(weatherManager: mockWeatherManager, locationManager: mockLocationManager)
        viewModel.delegate = mockDelegate
        
        // Clear UserDefaults before each test
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
    override func tearDown() {
        viewModel = nil
        mockWeatherManager = nil
        mockLocationManager = nil
        mockDelegate = nil
        super.tearDown()
    }
    
    func testFetchWeatherForCitySuccess() {
        // Arrange
        let expectedWeather = WeatherModel(conditionId: 72, cityName: "San Francisco", temperature: 800, icon: "icon")
        mockWeatherManager.result = .success(expectedWeather)
        
        // Act
        viewModel.fetchWeather(forCity: "San Francisco")
        
        // Assert
        XCTAssertTrue(mockWeatherManager.fetchWeatherCalled)
        XCTAssertTrue(mockDelegate.didUpdateWeatherCalled)
        XCTAssertEqual(mockDelegate.weather?.cityName, "San Francisco")
    }
    
    func testFetchWeatherForCityFailure() {
        // Arrange
        let expectedError = WeatherError.networkError(NSError(domain: "", code: 0, userInfo: nil))
        mockWeatherManager.result = .failure(expectedError)
        
        // Act
        viewModel.fetchWeather(forCity: "Invalid City")
        
        // Assert
        XCTAssertTrue(mockWeatherManager.fetchWeatherCalled)
        XCTAssertTrue(mockDelegate.didFailWithErrorCalled)
        XCTAssertNotNil(mockDelegate.error)
    }
    
    func testFetchWeatherForCurrentLocation() {
        // Act
        viewModel.fetchWeatherForCurrentLocation()
        
        // Assert
        XCTAssertTrue(mockLocationManager.requestLocationCalled)
    }
    
    func testDidUpdateLocationsSuccess() {
        // Arrange
        let expectedWeather = WeatherModel(conditionId: 72, cityName: "San Francisco", temperature: 800, icon: "icon")
        mockWeatherManager.result = .success(expectedWeather)
        
        // Act
        viewModel.fetchWeatherForCurrentLocation()
        // Assert
        XCTAssertTrue(mockDelegate.didUpdateWeatherCalled)
        XCTAssertEqual(mockDelegate.weather?.cityName, "San Francisco")
    }
    
    func testDidFailWithError() {
        // Arrange
        let expectedError = WeatherError.networkError(NSError(domain: "", code: 0, userInfo: nil))
        mockWeatherManager.result = .failure(expectedError)
        
        // Act
        viewModel.fetchWeatherForCurrentLocation()
        
        // Assert
        XCTAssertTrue(mockDelegate.didFailWithErrorCalled)
        XCTAssertNotNil(mockDelegate.error)
    }
    
    func testNoDuplicateCitiesInSearchHistory() {
        // Arrange
        let city = "San Francisco"
        
        // Act
        viewModel.addCityToSearchHistory(city)
        viewModel.addCityToSearchHistory(city) // Add the same city again
        
        // Assert
        XCTAssertEqual(viewModel.fetchSearchHistory().count, 1)
    }
    
    func testSearchHistoryPersistsBetweenSessions() {
        // Arrange
        let city1 = "San Francisco"
        let city2 = "New York"
        
        // Act
        viewModel.addCityToSearchHistory(city1)
        viewModel.addCityToSearchHistory(city2)
        
        // Reinitialize viewModel to simulate app relaunch
        viewModel = WeatherViewModel()
        
        // Assert
        let searchHistory = viewModel.fetchSearchHistory()
        XCTAssertEqual(searchHistory.count, 2)
        XCTAssertTrue(searchHistory.contains(city1))
        XCTAssertTrue(searchHistory.contains(city2))
    }
    
}
