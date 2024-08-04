//
//  WeatherRowView.swift
//  WeatherCity
//
//  Created by MAHESHWARAN on 04/08/24.
//

import SwiftUI

struct WeatherRowView: View {
  
  private var inputItem: InputItem
  
  init(_ style: Style) {
    self.inputItem = .init(style: style)
  }
  
  var body: some View {
    VStack(spacing: inputItem.spacing) {
      mainView
    }
    .background(inputItem.backgroundColor,
                in: .rect(cornerRadius: inputItem.cornerRadius))
    .accessibilityElement(children: .contain)
  }
  
  @ViewBuilder
  private var mainView: some View {
    Group {
      switch inputItem.style {
      case .mix(let time, let image, let value):
        title(for: time, padding: 10)
        
        iconView(for: image)
        
        title(for: value, padding: 16)
      }
    }
    .padding(.vertical, 16)
  }
  
  private func iconView(for name: String) -> some View {
    Image(systemName: name)
      .renderingMode(.template)
      .frame(width: 24, height: 24)
      .foregroundStyle(inputItem.iconColor)
      .padding(.horizontal, 18)
  }
  
  private func title(for value: String, padding: CGFloat) -> some View {
    Text(value)
      .padding(.horizontal, padding)
      .foregroundStyle(inputItem.foregroundColor)
    
  }
}

// MARK: - Style

extension WeatherRowView {
  
  enum Style {
    case mix(time: String, icon: String, temperature: String)
  }
  
  struct InputItem {
    var style: Style
    
    var cornerRadius: CGFloat
    var spacing: CGFloat
    
    var backgroundColor: Color
    var foregroundColor: Color
    var iconColor: Color
    
    var isSelected: Bool
    
    init(style: Style,
         isSelected: Bool = false,
         cornerRadius: CGFloat = 30,
         spacing: CGFloat = 16) {
      
      self.style = style
      self.isSelected = isSelected
      self.cornerRadius = cornerRadius
      self.spacing = spacing
      
      backgroundColor = isSelected ? .blue.opacity(0.2) : Color(.systemBackground)
      iconColor = isSelected ? Color(.label) : .secondary
      
      switch style {
      case .mix:
        foregroundColor = isSelected ? Color(.label) : .secondary
      }
    }
  }
}

// MARK: - Modifiers

extension WeatherRowView {
  
  func cornerRadius(_ value: CGFloat) -> Self {
    var newView = self
    newView.inputItem.cornerRadius = value
    return newView
  }
  
  func spacing(_ value: CGFloat) -> Self {
    var newView = self
    newView.inputItem.spacing = value
    return newView
  }
  
  func isSelected(_ value: Bool) -> Self {
    var newView = self
    newView.inputItem.isSelected = value
    return newView
  }
  
  func backgroundColor(_ color: Color) -> Self {
    var newView = self
    newView.inputItem.backgroundColor = color
    return newView
  }
  
  func foregroundColor(_ color: Color) -> Self {
    var newView = self
    newView.inputItem.foregroundColor = color
    return newView
  }
  
  func iconColor(_ color: Color) -> Self {
    var newView = self
    newView.inputItem.iconColor = color
    return newView
  }
}
