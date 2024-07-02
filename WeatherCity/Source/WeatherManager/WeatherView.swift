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
  
  @StateObject private var locationManager = LocationManager()
  @State private var selectedCity: City?

  // MARK: - View
  
  var body: some View {
    mainView
      .task(id: locationManager.currentLocation) { await fetchCity() }
      .task(id: selectedCity) { await fetchWeather() }
  }
  
  @ViewBuilder
  private var mainView: some View {
    if !locationManager.isAuthorized {
      locationDeniedView
    } else if let currentWeather, !isLoading {
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
  
  @ViewBuilder
  private var cityView: some View {
    if let selectedCity {
      Text(selectedCity.name)
        .font(.title)
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
  
  private func fetchCity() async {
    guard let location = locationManager.currentLocation, selectedCity == nil else {
      return
    }
    selectedCity = location
  }
  
  private func fetchWeather() async {
    guard let selectedCity else { return }
    isLoading = true
    
    Task.detached { @MainActor in
      
      currentWeather = await weatherManager.currentWeather(for: selectedCity.weatherItem)
    }
    isLoading = false
  }
}

// MARK: - Location Denied View

extension WeatherView {
  
  private var locationDeniedView: some View {
    VStack {
      Image(systemName: "gear")
        .resizable()
        .font(.title)
        .frame(width: 100, height: 100)
      
      Label("Location Services", systemImage: "gear")
      
      Text("""
      1. Tap on the button below to go to `Privacy and Security`
      2. Tap on `Location Services`
      3. Locate the `WeatherCity` app and tap on it.
      4. Change the settings to `While using the App`
      """)
      .multilineTextAlignment(.leading)
      
      Link("Open Settings", destination: .init(string: UIApplication.openSettingsURLString)!)
        .buttonStyle(.borderedProminent)
        .clipShape(.capsule)
    }
  }
}

// MARK: - Preview

#Preview {
  WeatherView()
}
