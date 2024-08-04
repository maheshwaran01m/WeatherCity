//
//  ContentView.swift
//  WeatherCity
//
//  Created by MAHESHWARAN on 30/06/24.
//

import SwiftUI

struct ContentView: View {
  
  var body: some View {
//    WeatherView()
    WeatherContainerView(latitude: 37.3230, longitude: 122.0322)
  }
}

// MARK: - Preview

#Preview {
  ContentView()
}
