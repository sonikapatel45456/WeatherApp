//
//  SearchHistoryViewControllerTests.swift
//  WeatherAppTests
//
//  Created by Sonika Patel on 16/08/24.
//

import XCTest
@testable import WeatherApp

class SearchHistoryViewControllerTests: XCTestCase {
    
    var viewController: SearchHistoryViewController!
    
    override func setUp() {
        super.setUp()
        viewController = SearchHistoryViewController()
        viewController.loadViewIfNeeded()
    }
    
    override func tearDown() {
        viewController = nil
        super.tearDown()
    }
    
    func testNumberOfRowsInTableView() {
        // Arrange
        viewController.searchHistory = ["New York", "Los Angeles", "San Francisco"]
        
        // Act
        let numberOfRows = viewController.tableView.numberOfRows(inSection: 0)
        
        // Assert
        XCTAssertEqual(numberOfRows, 3, "Number of rows should match the number of items in the search history.")
    }
    
    func testCellForRowAtIndexPath() {
        // Arrange
        viewController.searchHistory = ["New York"]
        let indexPath = IndexPath(row: 0, section: 0)
        
        // Act
        let cell = viewController.tableView(viewController.tableView, cellForRowAt: indexPath)
        
        // Assert
        XCTAssertEqual(cell.textLabel?.text, "New York", "The cell should display the correct city name.")
    }
    
    func testDidSelectRowAtIndexPath() {
        // Arrange
        viewController.searchHistory = ["New York", "Los Angeles", "San Francisco"]
        var selectedCity: String?
        viewController.onCitySelected = { city in
            selectedCity = city
        }
        
        // Act
        let indexPath = IndexPath(row: 1, section: 0)
        viewController.tableView(viewController.tableView, didSelectRowAt: indexPath)
        
        // Assert
        XCTAssertEqual(selectedCity, "Los Angeles", "The selected city should be passed back correctly.")
    }
    
}
