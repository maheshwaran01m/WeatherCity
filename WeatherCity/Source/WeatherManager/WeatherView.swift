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
  
  @Environment(\.scenePhase) private var scenePhase
  @State private var currentWeather: CurrentWeather?
  @State private var isLoading = false
  
  @StateObject private var locationManager = LocationManager()
  @State private var selectedCity: City?
  
  @State private var showCityList = false
  @State private var timeZone = TimeZone.current
  
  @State private var hourlyForecast: Forecast<HourWeather>?
  @State private var dayilyForecast: Forecast<DayWeather>?
  
  @State private var barWidth: Double = .zero

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
      ScrollView {
        weatherView(for: currentWeather)
      }
      .scrollIndicators(.hidden)
    } else {
      placeholderView
    }
  }
}

// MARK: - Weather

extension WeatherView {
  
  private func weatherView(for item: CurrentWeather) -> some View {
    VStack {
      dateView(for: item)
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
      temperatureValue
      
      Text(item.condition.description)
        .font(.title3)
      
      Divider()
      hourlyWeatherView
      
      Divider()
      dailyWeatherView
    }
    .background(content: backgroundView)
    .safeAreaInset(edge: .bottom, content: bottomView)
    .preferredColorScheme(.dark)
    .onChange(of: scenePhase, perform: updateCurrentCity)
  }
  
  @ViewBuilder
  private var cityView: some View {
    if let selectedCity {
      Text(selectedCity.name)
        .font(.title)
    }
  }
  
  @ViewBuilder
  private func dateView(for item: CurrentWeather) -> some View {
    Text(item.date.localeDate(for: timeZone))
    Text(item.date.localeTime(for: timeZone))
  }
  
  private func temperatureView(for item: CurrentWeather) -> some View {
    let temp = weatherManager.temperatureFormatter.string(
      from: item.temperature)
    
    return Text(temp)
      .font(.title2)
  }
  
  @ViewBuilder
  private var temperatureValue: some View {
    if let temperature = hourlyForecast?.map({ $0.temperature }),
       let high = temperature.max(), let low = temperature.min() {
      Text("H: \(high) L: \(low)")
        .bold()
    }
  }
  
  @ViewBuilder
  private func bottomView() -> some View {
    VStack {
      WeatherAttributionView()
        .tint(.white)
      
      Button {
        showCityList.toggle()
      } label: {
        Image(systemName: "list.star")
      }
      .padding()
      .background(Color(.darkGray), in: .circle)
      .foregroundStyle(.white)
      .padding(.horizontal)
      .frame(maxWidth: .infinity, alignment: .trailing)
    }
    .fullScreenCover(isPresented: $showCityList) {
      CityListView(locationManager.currentLocation,
                   locationManager: locationManager,
                   selectedCity: $selectedCity)
    }
  }
  
  // MARK: - Hourly Weather
  
  @ViewBuilder
  var hourlyWeatherView: some View {
    if let hourlyForecast {
      Text("Hourly Forecast")
        .font(.title)
      Text("Next 25 hours")
        .font(.caption)
      
      ScrollView(.horizontal) {
        HStack(spacing: 4) {
          ForEach(hourlyForecast, id: \.date) { hour in
            VStack(spacing: 0) {
              Text(hour.date.localeTime(for: timeZone))
              
              Divider()
              Spacer()
              
              Image(systemName: hour.symbolName)
                .renderingMode(.original)
                .symbolVariant(.fill)
                .font(.system(size: 22))
                .padding(.bottom, 3)
              
              if hour.precipitationChance > 0 {
                Text("\((hour.precipitationChance * 100).formatted(.number.precision(.fractionLength(0))))%")
                  .foregroundStyle(Color.cyan)
                  .bold()
              }
              Spacer()
              
              Text(weatherManager.temperatureFormatter.string(from: hour.temperature))
            }
          }
        }
        .font(.system(size: 13))
        .frame(height: 100)
      }
      .scrollIndicators(.hidden)
      .background(
        RoundedRectangle(cornerRadius: 16).fill(Color.secondary.opacity(0.2))
      )
    }
  }
  
  // MARK: - Daily Weather
  
  @ViewBuilder
  var dailyWeatherView: some View {
    if let dayilyForecast {
      Text("Ten Day Forecast")
        .font(.title)
      
      VStack {
        let maxDayTemp = dayilyForecast.map { $0.highTemperature.value }.max() ?? 0
        let minDayTemp = dayilyForecast.map { $0.lowTemperature.value }.min() ?? 0
        let tempRange = maxDayTemp - minDayTemp
        
        ForEach(dayilyForecast, id: \.date) { day in
          LabeledContent {
            HStack(spacing: 0) {
              VStack {
                Image(systemName: day.symbolName)
                  .renderingMode(.original)
                  .symbolVariant(.fill)
                  .font(.system(size: 20))
                
                if day.precipitationChance > 0 {
                  Text("\((day.precipitationChance * 100).formatted(.number.precision(.fractionLength(0))))%")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.cyan)
                    .bold()
                }
              }
              .frame(width: 25)
              
              Text(weatherManager.temperatureFormatter.string(from: day.lowTemperature))
                .font(.system(size: 12, weight: .bold))
                .frame(width: 50)
                .foregroundColor(.white)
              
              RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.2))
                .frame(height: 5)
                .readSize { barWidth = $0.width }
                .overlay {
                  let degreeFactor = barWidth / tempRange
                  let dayRangeWidth = (day.highTemperature.value - day.lowTemperature.value) * degreeFactor
                  let xOffset = (day.lowTemperature.value - minDayTemp) * degreeFactor
                  
                  HStack {
                    RoundedRectangle(cornerRadius: 10)
                      .fill(
                        LinearGradient(
                          gradient: Gradient(colors: [.green, .orange]),
                          startPoint: .leading, endPoint: .trailing
                        ))
                      .frame(width: dayRangeWidth, height: 5)
                    
                    Spacer()
                  }
                  .offset(x: xOffset)
                }
              
              Text(weatherManager.temperatureFormatter.string(from: day.highTemperature))
                .font(.system(size: 14, weight: .bold))
                .frame(width: 50)
                .foregroundColor(.white)
            }
          } label: {
            Text(day.date.localeDate(for: timeZone))
              .frame(width: 40, alignment: .leading)
          }
          .frame(height: 35)
        }
      }
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(Color.secondary.opacity(0.2))
      )
    }
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
      timeZone = await locationManager.getTimeZone(for: selectedCity.weatherItem.coordinates)
      
      hourlyForecast = await weatherManager.hourlyForecast(for: selectedCity.weatherItem)
      dayilyForecast = await weatherManager.dailyForecast(for: selectedCity.weatherItem)
    }
    isLoading = false
  }
  
  private func updateCurrentCity(_ phase: ScenePhase) {
    guard phase == .active else { return }
    selectedCity = locationManager.currentLocation
    Task {
      await fetchWeather()
    }
  }
}

// MARK: - Background View

extension WeatherView {
  
  @ViewBuilder
  private func backgroundView() -> some View {
    if selectedCity != nil,
       let condition = currentWeather?.condition {
      Image(condition.rawValue)
        .blur(radius: 3.0)
        .colorMultiply(.white.opacity(0.8))
    }
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
