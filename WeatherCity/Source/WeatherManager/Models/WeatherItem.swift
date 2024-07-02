//
//  WeatherItem.swift
//  WeatherCity
//
//  Created by MAHESHWARAN on 02/07/24.
//

import CoreLocation
import Foundation

// MARK: - WeatherItem

struct WeatherItem: Hashable {
  
  let latitude: Double
  let longitude: Double
  
  var coordinates: CLLocation {
    .init(latitude: latitude, longitude: longitude)
  }
  
  var coordinate2D: CLLocationCoordinate2D {
    .init(latitude: latitude, longitude: longitude)
  }
  
  static let preview = Self.init(latitude: 37.3346, longitude: -122.0090)
}

// MARK: - City

struct City: Identifiable, Hashable {
  let id: String
  var name: String
  var weatherItem: WeatherItem
  
  init(id: String = UUID().uuidString,
       name: String,
       weatherItem: WeatherItem) {
    
    self.id = id
    self.name = name
    self.weatherItem = weatherItem
  }
}
