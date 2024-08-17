//
//  MockCLLocationManager.swift
//  WeatherAppTests
//
//  Created by Sonika Patel on 16/08/24.
//

import XCTest
import CoreLocation
@testable import WeatherApp

class MockCLLocationManager: CLLocationManager {
    var requestLocationCalled = false
    
    // Store the delegate internally
    private var _delegate: CLLocationManagerDelegate?
    
    // Override the delegate property
    override var delegate: CLLocationManagerDelegate? {
        get { return _delegate }
        set { _delegate = newValue }
    }
    
    override func requestLocation() {
        requestLocationCalled = true
        
        delegate?.locationManager?(self, didUpdateLocations: [CLLocation(latitude: 37.7749, longitude: -122.4194)])
    }
}

