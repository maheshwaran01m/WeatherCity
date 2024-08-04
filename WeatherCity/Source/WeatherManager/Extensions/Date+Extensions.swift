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
  
  // Get the date and time one hour ago from now
  func reduceOneHourFromCurrentTime() -> Date {
    let currentDate = Date()
    return Calendar.current.date(byAdding: .hour, value: -1, to: currentDate) ?? .now
  }
  
  func isToday() -> Bool {
    return Calendar.current.isDateInToday(self)
  }
}

extension Calendar {
  
  func endOfDay(for date: Date) -> Date? {
    if let tomorrow = (self as NSCalendar).date(
      byAdding: .day, value: 1,
      to: date, options: .matchStrictly) {
      // Reduce 1 sec from tomorrow's start of day, to get end of today
      return self.startOfDay(for: tomorrow) - 1
    }
    return nil
  }
}
