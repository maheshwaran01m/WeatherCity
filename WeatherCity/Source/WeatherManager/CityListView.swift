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
  
  init(_ currentLocation: City?,
       selectedCity: Binding<City?> = .constant(nil)) {
    self.currentLocation = currentLocation
    _selectedCity = selectedCity
  }
  
  var body: some View {
    NavigationStack {
      List {
        if let currentLocation {
          Text(currentLocation.name)
            .onTapGesture {
              selectedCity = currentLocation
              dismiss()
            }
        }
        
        ForEach(City.cities) { city in
          Text(city.name)
            .onTapGesture {
              selectedCity = city
              dismiss()
            }
        }
      }
      .listStyle(.plain)
      .navigationTitle("My City")
      .navigationBarTitleDisplayMode(.inline)
      .preferredColorScheme(.dark)
    }
  }
}

#Preview {
  CityListView(.previewCity, selectedCity: .constant(.previewCity))
}
