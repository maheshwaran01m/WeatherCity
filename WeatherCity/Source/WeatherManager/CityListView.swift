//
//  CityListView.swift
//  WeatherCity
//
//  Created by MAHESHWARAN on 02/07/24.
//

import SwiftUI

struct CityListView: View {
  
  @Environment(\.dismiss) private var dismiss
  
  private let currentLocation: City?
  
  @Binding var selectedCity: City?
  
  @ObservedObject private var locationManager: LocationManager
  
  init(_ currentLocation: City?,
       locationManager: LocationManager,
       selectedCity: Binding<City?> = .constant(nil)) {
    self.currentLocation = currentLocation
    self.locationManager = locationManager
    _selectedCity = selectedCity
  }
  
  var body: some View {
    NavigationStack {
      List {
        Group {
          if let currentLocation {
            CityRowView(locationManager, city: currentLocation)
              .onTapGesture {
                selectedCity = currentLocation
                dismiss()
              }
          }
          
          ForEach(City.cities) { city in
            CityRowView(locationManager, city: city)
              .onTapGesture {
                selectedCity = city
                dismiss()
              }
          }
        }
        .clipShape(.rect(cornerRadius: 8))
        .listRowInsets(.init(top: 0, leading: 20, bottom: 5, trailing: 20))
      }
      .listStyle(.plain)
      .navigationTitle("My City")
      .navigationBarTitleDisplayMode(.inline)
      .preferredColorScheme(.dark)
    }
  }
}

// MARK: - Preview

#Preview {
  CityListView(.preview, locationManager: .init(),
               selectedCity: .constant(.preview))
}
