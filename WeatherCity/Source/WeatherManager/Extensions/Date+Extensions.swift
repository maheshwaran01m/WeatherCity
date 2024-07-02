//
//  Date+Extensions.swift
//  WeatherCity
//
//  Created by MAHESHWARAN on 02/07/24.
//

import Foundation

extension Date {
  
  func localeDate(for timeZone: TimeZone) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    dateFormatter.timeZone = timeZone
    
    return dateFormatter.string(from: self)
  }
  
  func localeTime(for timeZone: TimeZone) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .none
    dateFormatter.timeStyle = .short
    dateFormatter.timeZone = timeZone
    
    return dateFormatter.string(from: self)
  }
}
