//
//  WeatherView.swift
//  WeatherCity
//
//  Created by MAHESHWARAN on 30/06/24.
//

import CoreLocation
import SwiftUI
import WeatherKit

struct WeatherView: View {
  
  // MARK: - Internal Property
  
  private let weatherManager = WeatherManager.shared
  
  @State private var currentWeather: CurrentWeather?
  @State private var isLoading = false

  // MARK: - View
  
  var body: some View {
    mainView
      .task { await fetchWeather() }
  }
  
  @ViewBuilder
  private var mainView: some View {
    if let currentWeather, !isLoading {
      weatherView(for: currentWeather)
    } else {
      placeholderView
    }
  }
}

// MARK: - Weather

extension WeatherView {
  
  private func weatherView(for item: CurrentWeather) -> some View {
    VStack {
      Image(systemName: item.symbolName)
        .renderingMode(.original)
        .symbolVariant(.fill)
        .font(.system(size: 60, weight: .bold))
        .padding()
        .background {
          RoundedRectangle(cornerRadius: 16)
            .fill(.secondary.opacity(0.2))
        }
      
      temperatureView(for: item)
      
      Text(item.condition.description)
        .font(.title3)
      
      WeatherAttributionView()
    }
  }
  
  private func temperatureView(for item: CurrentWeather) -> some View {
    let temp = weatherManager.temperatureFormatter.string(
      from: item.temperature)
    
    return Text(temp)
      .font(.title2)
  }
}

// MARK: - Placeholder

extension WeatherView {
  
  @ViewBuilder
  private var placeholderView: some View {
    if isLoading {
      VStack {
        ProgressView()
        
        Text("Fetching...")
      }
    } else {
      Text("No Weather")
    }
  }
}

// MARK: - Fetch Weather

extension WeatherView {
  
  private func fetchWeather() async {
    isLoading = true
    
    Task.detached { @MainActor in
      
      currentWeather = await weatherManager.currentWeather(for: .preview)
    }
    isLoading = false
  }
}

// MARK: - Preview

#Preview {
  WeatherView()
}
