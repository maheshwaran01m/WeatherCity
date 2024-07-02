//
//  WeatherManager.swift
//  WeatherCity
//
//  Created by MAHESHWARAN on 30/06/24.
//

import Foundation
import CoreLocation
import WeatherKit

class WeatherManager {
  
  static let shared = WeatherManager()
  
  private let service = WeatherService.shared
  
  private(set) var temperatureFormatter: MeasurementFormatter = {
    $0.numberFormatter.maximumFractionDigits = 0
    return $0
  }(MeasurementFormatter())
}

// MARK: - Current Weather

extension WeatherManager {
  
  func currentWeather(for item: WeatherItem) async -> CurrentWeather? {
    await Task.detached(priority: .userInitiated) {
      
      return try? await self.service.weather(for: item.coordinates, including: .current)
      
    }.value
  }
}

// MARK: - Hourly Weather

extension WeatherManager {
  
  func hourlyForecast(for item: WeatherItem) async -> Forecast<HourWeather>? {
    await Task.detached(priority: .userInitiated) {
      
      return try? await self.service.weather(for: item.coordinates, including: .hourly)
      
    }.value
  }
}

// MARK: - Daily Weather

extension WeatherManager {
  
  func dailyForecast(for item: WeatherItem) async -> Forecast<DayWeather>? {
    await Task.detached(priority: .userInitiated) {
      
      return try? await self.service.weather(for: item.coordinates, including: .daily)
      
    }.value
  }
}

// MARK: - WeatherAttribution

extension WeatherManager {
  
  func weatherAttribution() async -> WeatherAttribution? {
    await Task.detached(priority: .userInitiated) {
      
      return try? await self.service.attribution
      
    }.value
  }
}
