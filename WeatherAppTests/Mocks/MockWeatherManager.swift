//
//  MockWeatherManager.swift
//  WeatherAppTests
//
//  Created by Sonika Patel on 16/08/24.
//

import XCTest
import CoreLocation
@testable import WeatherApp

class MockWeatherManager: WeatherManager {
    var fetchWeatherCalled = false
    var result: Result<WeatherModel, WeatherError>?
    
    override func fetchWeather(cityName: String, completion: @escaping (Result<WeatherModel, WeatherError>) -> Void) {
        fetchWeatherCalled = true
        if let result = result {
            completion(result)
        }
    }
    
    override func fetchWeather(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherModel, WeatherError>) -> Void) {
        fetchWeatherCalled = true
        if let result = result {
            completion(result)
        }
    }
}
