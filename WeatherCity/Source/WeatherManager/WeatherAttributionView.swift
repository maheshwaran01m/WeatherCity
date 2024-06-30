//
//  WeatherAttributionView.swift
//  WeatherCity
//
//  Created by MAHESHWARAN on 30/06/24.
//

import CoreLocation
import SwiftUI
import WeatherKit

struct WeatherAttributionView: View {
  
  // MARK: - Internal View
  
  @Environment(\.colorScheme) private var colorScheme
  private let weatherManager = WeatherManager.shared
  
  @State private var attribution: WeatherAttribution?
  
  // MARK: - View
  
  var body: some View {
   mainView
  }
  
  @ViewBuilder
  private var mainView: some View {
    if let attribution {
      attributionView(for: attribution)
    } else {
      placeholderView
    }
  }
  
  private func attributionView(for item: WeatherAttribution) -> some View {
    VStack {
      AsyncImage(
        url: colorScheme == .dark ? item.combinedMarkDarkURL : item.combinedMarkLightURL) {
          $0
            .resizable()
            .scaledToFit()
            .frame(height: 20)
          
        } placeholder: {
          ProgressView()
        }
      
      Text(String("[\(item.serviceName)](\(item.legalPageURL)"))
    }
  }
  
  private var placeholderView: some View {
    Color.gray.opacity(0.01)
  }
}

// MARK: - Fetch

extension WeatherAttributionView {
  
  private func fetch() async {
    Task.detached { @MainActor in
      
      attribution = await weatherManager.weatherAttribution()
    }
  }
}

// MARK: - Preview

#Preview {
  WeatherAttributionView()
}
