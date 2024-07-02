//
//  LocationManager.swift
//  WeatherCity
//
//  Created by MAHESHWARAN on 02/07/24.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject {
  
  let manager = CLLocationManager()
  
  @Published var userLocation: CLLocation?
  @Published var currentLocation: City?
  @Published var isAuthorized = false
  
  override init() {
    super.init()
    manager.delegate = self
  }
}

extension LocationManager: CLLocationManagerDelegate {
  
  private func startLocationServices() {
    guard manager.authorizationStatus == .authorizedAlways ||
            manager.authorizationStatus == .authorizedWhenInUse else {
      isAuthorized = false
      manager.requestWhenInUseAuthorization()
      return
    }
    manager.startUpdatingLocation()
    isAuthorized = true
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    userLocation = locations.last
    updateCurrentCity()
  }
  
  private func updateCurrentCity() {
    guard let userLocation else { return }
    Task {
      let name = await getLocationName(for: userLocation)
      currentLocation = City(name: name, weatherItem: .init(
        latitude: userLocation.coordinate.latitude,
        longitude: userLocation.coordinate.longitude)
      )
    }
  }
  
  private func getLocationName(for location: CLLocation) async -> String {
    let name = try? await CLGeocoder().reverseGeocodeLocation(location).first?.locality
    
    return name ?? "No Data"
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    switch manager.authorizationStatus {
    case .authorizedAlways, .authorizedWhenInUse:
      isAuthorized = true
      manager.requestLocation()
      
    case .notDetermined:
      isAuthorized = false
      manager.requestWhenInUseAuthorization()
    case .denied:
      isAuthorized = false
    default:
      startLocationServices()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
    debugPrint(error.localizedDescription)
  }
}
