//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by Sonika Patel on 16/08/24.
//

import Foundation
import CoreLocation

enum WeatherError: Error {
    case networkError(Error)
    case dataError
    case parsingError(Error)
}

class WeatherManager {
    private let apiKey = "0e3fb4c31095dcaef0e0d2ba2e5eedf8"
    private let baseUrl = "https://api.openweathermap.org/data/2.5/weather"
    private let session: URLSession
    typealias WeatherCompletion = (Result<WeatherModel, WeatherError>) -> Void
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func fetchWeather(cityName: String, completion: @escaping WeatherCompletion) {
        var components = URLComponents(string: baseUrl)
        
        components?.queryItems = [
            URLQueryItem(name: "q", value: cityName),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "imperial")
        ]
        guard let url = components?.url else {
            completion(.failure(.dataError))
            return
        }
        performRequest(with: url, completion: completion)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping WeatherCompletion) {
        var components = URLComponents(string: baseUrl)
        components?.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "imperial")
        ]
        guard let url = components?.url else {
            completion(.failure(.dataError))
            return
        }
        performRequest(with: url, completion: completion)
    }
    
    private func performRequest(with url: URL, completion: @escaping WeatherCompletion) {
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            guard let safeData = data else {
                completion(.failure(.dataError))
                return
            }
            let result = self.parseJSON(safeData)
            completion(result)
        }
        task.resume()
    }
    
    private func parseJSON(_ weatherData: Data) -> Result<WeatherModel, WeatherError> {
        do {
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            let icon = decodedData.weather[0].icon
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp, icon: icon)
            return .success(weather)
        } catch {
            return .failure(.parsingError(error))
        }
        
    }
    
}
