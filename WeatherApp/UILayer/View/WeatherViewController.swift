//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Sonika Patel on 16/08/24.
//

import UIKit

class WeatherViewController: UIViewController, WeatherViewModelDelegate {

    var viewModel = WeatherViewModel()

    lazy var conditionImageView: LoadingImageView = {
        let imageView = LoadingImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.2
        imageView.layer.shadowOffset = CGSize(width: 0, height: 4)
        imageView.layer.shadowRadius = 6
        return imageView
    }()

    lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        label.textAlignment = .center
        label.textColor = .systemBlue
        return label
    }()
    
    lazy var cityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        label.textAlignment = .center
        label.textColor = .darkGray
        return label
    }()
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search city"
        searchBar.delegate = self
        searchBar.showsSearchResultsButton = true
        
        if let textField = searchBar.searchTextField.superview {
            let backgroundView = textField.subviews.first
            backgroundView?.layer.borderColor = UIColor.clear.cgColor
            backgroundView?.layer.borderWidth = 0
        }
        searchBar.backgroundImage = UIImage()
        return searchBar
    }()

    lazy var locationButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let icon = UIImage(systemName: "location.fill", withConfiguration: config)
        button.setImage(icon, for: .normal)
        button.tintColor = .systemBlue
        button.backgroundColor = UIColor(white: 0.95, alpha: 1)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(locationPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var searchStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [searchBar, locationButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .fill
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Weather App"

        viewModel.delegate = self
        view.backgroundColor = UIColor.white
        setupUI()
        viewModel.fetchWeatherForCurrentLocation()
    }

    private func setupUI() {
        view.addSubview(conditionImageView)
        view.addSubview(temperatureLabel)
        view.addSubview(cityLabel)
        view.addSubview(searchStackView)

        setupConstraints()
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            searchStackView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            searchStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            searchStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            locationButton.widthAnchor.constraint(equalToConstant: 38),
            locationButton.heightAnchor.constraint(equalToConstant: 38),

            conditionImageView.topAnchor.constraint(equalTo: searchStackView.bottomAnchor, constant: 30),
            conditionImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            conditionImageView.heightAnchor.constraint(equalToConstant: 120),
            conditionImageView.widthAnchor.constraint(equalToConstant: 120),
            
            temperatureLabel.topAnchor.constraint(equalTo: conditionImageView.bottomAnchor, constant: 30),
            temperatureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            cityLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 10),
            cityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // MARK: - WeatherViewModelDelegate Methods
    func didUpdateWeather(_ viewModel: WeatherViewModel, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
            if let iconUrl = weather.iconUrl {
                self.conditionImageView.loadImage(from: iconUrl)
            }
        }
    }
    
    func didFailWithError(error: WeatherError) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func locationPressed() {
        viewModel.fetchWeatherForCurrentLocation()
    }
    
    @objc func showSearchHistory() {
        let historyVC = SearchHistoryViewController()
        historyVC.searchHistory = viewModel.fetchSearchHistory()
        historyVC.onCitySelected = { [weak self] selectedCity in
            self?.searchBar.text = selectedCity
            self?.viewModel.fetchWeather(forCity: selectedCity)
        }
        // Could have been improve by coordinator pattern
        present(historyVC, animated: true, completion: nil)
    }

    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        showSearchHistory()
    }

}

// MARK: - UISearchBarDelegate
extension WeatherViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        if let city = searchBar.text, !city.isEmpty {
            viewModel.addCityToSearchHistory(city)
            viewModel.fetchWeather(forCity: city)
        }
    }
}

