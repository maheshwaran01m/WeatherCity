//
//  ViewExtensions.swift
//  WeatherCity
//
//  Created by MAHESHWARAN on 02/07/24.
//

import SwiftUI

extension View {
  
  func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
    background(
      GeometryReader { geometryProxy in
        Color.clear
          .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
      }
    )
    .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
  }
}

fileprivate struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
