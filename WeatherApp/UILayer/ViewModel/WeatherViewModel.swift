//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Sonika Patel on 16/08/24.
//

import Foundation
import CoreLocation

protocol WeatherViewModelDelegate: AnyObject {
    func didUpdateWeather(_ viewModel: WeatherViewModel, weather: WeatherModel)
    func didFailWithError(error: WeatherError)
}

class WeatherViewModel: NSObject {
    
    weak var delegate: WeatherViewModelDelegate?
    
    var weatherManager: WeatherManager
    var locationManager: CLLocationManager
    private(set) var searchHistory: [String] = []

    private let searchHistoryKey = "searchHistory"

    init(
        weatherManager: WeatherManager = WeatherManager(),
        locationManager: CLLocationManager = CLLocationManager()
    ) {
        self.weatherManager = weatherManager
        self.locationManager = locationManager
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        loadSearchHistory()
    }
    
    func fetchWeather(forCity city: String) {
        weatherManager.fetchWeather(cityName: city) { [weak self] result in
            self?.handleWeatherResult(result)
            self?.addCityToSearchHistory(city)
        }
    }
    
    func fetchWeatherForCurrentLocation() {
        locationManager.requestLocation()
    }
    
    func addCityToSearchHistory(_ city: String) {
        if !searchHistory.contains(city) {
            searchHistory.append(city)
            saveSearchHistory()
        }
    }
    
    func fetchSearchHistory() -> [String] {
        return searchHistory
    }
    
    private func saveSearchHistory() {
        UserDefaults.standard.set(searchHistory, forKey: searchHistoryKey)
    }
    
    private func loadSearchHistory() {
        searchHistory = UserDefaults.standard.stringArray(forKey: searchHistoryKey) ?? []
    }

    private func handleWeatherResult(_ result: Result<WeatherModel, WeatherError>) {
        switch result {
        case .success(let weather):
            delegate?.didUpdateWeather(self, weather: weather)
        case .failure(let error):
            delegate?.didFailWithError(error: error)
        }
    }
}

//MARK: - CLLocationManagerDelegate
extension WeatherViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon) { [weak self] result in
                self?.handleWeatherResult(result)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
  
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
        fetchWeatherForCurrentLocation()
        } else if status == .denied || status == .restricted {
            delegate?.didFailWithError(error: .networkError(NSError(domain: "LocationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Location access denied."])))
        }
        
    }
    
}
