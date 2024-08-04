//
//  WeatherContainerViewModel.swift
//  WeatherCity
//
//  Created by MAHESHWARAN on 04/08/24.
//

import SwiftUI
import WeatherKit

class WeatherContainerViewModel: ObservableObject {
  
  // MARK: - Published Property
  
  @Published var showLoader = true
  
  @Published var records = [WeatherItem]()
  
  @Published var currentWeather: CurrentWeatherItem?
  
  // MARK: - Internal Property
  
  private let weatherService = WeatherService.shared
  private let latitude: Double
  private let longitude: Double
  
  private var temperatureFormatter: MeasurementFormatter = {
    $0.numberFormatter.maximumFractionDigits = 0
    return $0
  }(MeasurementFormatter())
  
  // MARK: - Init
  
  init(latitude: Double, longitude: Double) {
    self.latitude = latitude
    self.longitude = longitude
  }
  
  // MARK: - Internal Property
  
  var title: String {
    let day = Date().formatted(Date.FormatStyle().weekday(.wide))
    let time = Date.now.formatted(Date.FormatStyle().hour(.conversationalDefaultDigits(amPM: .wide)))
    
    return "\(day), \(time)"
  }
}

// MARK: - Fetch

extension WeatherContainerViewModel {
  
  func fetchRecords() async {
    do {
      let result = try await weatherService.weather(
        for: .init(latitude: latitude, longitude: longitude)
      )
      let currentWeather = constructCurrentWeather(using: result)
      let weatherItems = try await constructDayForecast(using: result)
      
      await MainActor.run { [weak self] in
        guard let self else { return }
        
        self.currentWeather = currentWeather
        self.records = weatherItems
        self.showLoader = false
      }
      
    } catch {
      await MainActor.run { [weak self] in
        self?.showLoader = false
      }
    }
  }
  
  private func constructCurrentWeather(using result: Weather) -> CurrentWeatherItem {
    .init(temperature: temperatureFormatter.string(from: result.currentWeather.temperature),
          condition: result.currentWeather.condition.description,
          icon: result.currentWeather.symbolName)
  }
  
  // MARK: - Day Weather
  
  private func constructDayForecast(using result: Weather) async throws -> [WeatherItem] {
    var weatherItems = [WeatherItem]()
    
    let daily = result.dailyForecast
      .prefix(7)
    
    for day in daily {
      let isToday = day.date.isToday()
      
      let query: WeatherQuery<Forecast<HourWeather>>
      
      if !isToday,
         let start = dateWithoutTime(day.date).start,
         let end = dateWithoutTime(day.date).end {
        
        query = .hourly(startDate: start, endDate: end)
      } else {
        query = .hourly
      }
      
      var hourly = try await weatherService.weather(
        for: .init(latitude: latitude, longitude: longitude),
        including: query).map { $0 }
      
      if isToday {
        hourly = hourly.filter { $0.date > Date.now.reduceOneHourFromCurrentTime() }
      }
      weatherItems.append(
        WeatherItem(
          title: day.date.formatted(Date.FormatStyle().weekday(.wide)),
          rows: constructRowItem(using: hourly, isToday: isToday),
          isCollapsed: isToday
        )
      )
    }
    return weatherItems
  }
  
  func dateWithoutTime(_ date: Date) -> (start: Date?, end: Date?) {
    var start: Date?, end: Date?
    let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    start = calendar.startOfDay(for: date)
    end = calendar.endOfDay(for: date)
    
    return (start, end)
  }
  
  // MARK: - Hourly Weather
  
  private func constructRowItem(using hourly: [HourWeather], isToday: Bool) -> [RowItem] {
    hourly
      .prefix(24)
      .compactMap {
        RowItem(
          time: timeString($0.date),
          icon: $0.symbolName,
          temperature: temperatureFormatter.string(from: $0.temperature),
          isSelected: timeString($0.date) == timeString(.now) && isToday
        )
      }
  }
  
  private func timeString(_ date: Date) -> String {
    date.formatted(Date.FormatStyle().hour(.conversationalDefaultDigits(amPM: .wide)))
  }
  
  // MARK: - Weather Icon
  
  func getWeatherForecastingIcon(for date: Int) async -> String? {
    do {
      let result = try await weatherService.weather(
        for: .init(latitude: latitude, longitude: longitude))
      
      return result.dailyForecast[date].symbolName
      
    } catch {
      return nil
    }
  }
}

// MARK: - WeatherItem

extension WeatherContainerViewModel {
  
  struct CurrentWeatherItem: Hashable {
    let temperature: String
    let condition: String
    let icon: String
  }
  
  struct WeatherItem: Hashable {
    let title: String
    var isCollapsed: Bool
    
    var rows: [RowItem]
    
    init(title: String,
         rows: [RowItem],
         isCollapsed: Bool = false) {
      self.title = title
      self.isCollapsed = isCollapsed
      self.rows = rows
    }
    
    var icon: String {
      isCollapsed ? "chevron.up" : "chevron.down"
    }
  }
  
  struct RowItem: Hashable {
    let time: String
    let icon: String
    let temperature: String
    let isSelected: Bool
  }
}
