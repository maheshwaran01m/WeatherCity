//
//  CityRowView.swift
//  WeatherCity
//
//  Created by MAHESHWARAN on 02/07/24.
//

import SwiftUI
import WeatherKit

struct CityRowView: View {
  
  // MARK: - Internal Property
  
  @ObservedObject private var locationManager: LocationManager
  
  @State private var currentWeather: CurrentWeather?
  @State private var isLoading = false
  @State private var timeZone = TimeZone.current
  
  private let weatherManager = WeatherManager.shared
  private let city: City
  
  // MARK: - Init
  
  init(_ locationManager: LocationManager, city: City) {
    self.locationManager = locationManager
    self.city = city
  }
  
  // MARK: - View
  
  var body: some View {
    VStack {
      mainView
    }
    .background(content: backgroundView)
    .task(id: city) { await fetchWeather() }
  }
  
  @ViewBuilder
  private var mainView: some View {
    if let currentWeather, !isLoading {
      VStack(alignment: .leading) {
        HStack {
          VStack(alignment: .leading) {
            Text(city.name)
              .font(.title)
              .scaledToFill()
              .minimumScaleFactor(0.5)
              .lineLimit(1)
            
            Text(currentWeather.date.localeDate(for: timeZone))
              .bold()
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          
          temperatureView(for: currentWeather)
        }
        Text(currentWeather.condition.description)
      }
      .padding()
      .frame(maxWidth: .infinity)
    } else {
      ProgressView()
    }
  }
  
  private func temperatureView(for item: CurrentWeather) -> some View {
    let temp = weatherManager.temperatureFormatter.string(
      from: item.temperature)
    
    return Text(temp)
      .font(.system(size: 60, weight: .thin, design: .rounded))
      .fixedSize()
  }
}

// MARK: - Background View

extension CityRowView {
  
  @ViewBuilder
  private func backgroundView() -> some View {
    if let condition = currentWeather?.condition {
      Image(condition.rawValue)
        .blur(radius: 3.0)
        .colorMultiply(.white.opacity(0.8))
    }
  }
}

extension CityRowView {
  
  private func fetchWeather() async {
    isLoading = true
    
    Task.detached { @MainActor in
      
      currentWeather = await weatherManager.currentWeather(for: city.weatherItem)
      timeZone = await locationManager.getTimeZone(for: city.weatherItem.coordinates)
    }
    isLoading = false
  }
}

// MARK: - Preview

#Preview {
  CityRowView(.init(), city: .preview)
}
