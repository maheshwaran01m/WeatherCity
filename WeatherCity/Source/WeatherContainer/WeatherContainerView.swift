//
//  WeatherContainerView.swift
//  WeatherCity
//
//  Created by MAHESHWARAN on 04/08/24.
//

import SwiftUI

struct WeatherContainerView: View {
  
  private typealias WeatherItem = WeatherContainerViewModel.WeatherItem
  private typealias CurrentWeatherItem = WeatherContainerViewModel.CurrentWeatherItem
  
  @StateObject private var viewModel: WeatherContainerViewModel
  
  // MARK: - Init
  
  init(latitude: Double, longitude: Double) {
    _viewModel = .init(wrappedValue: WeatherContainerViewModel(
      latitude: latitude, longitude: longitude)
    )
  }
  
  // MARK: - View
  
  var body: some View {
    NavigationStack {
      mainView
        .background(Color(.systemBackground))
        .task { await viewModel.fetchRecords() }
    }
  }
  
  @ViewBuilder
  private var mainView: some View {
    if !viewModel.records.isEmpty {
      listView
        .safeAreaInset(edge: .top, spacing: 0, content: headerView)
        .background(Color(.systemBackground))
      
    } else {
      Text("No Weather")
        .font(.title3)
    }
  }
  
  private var listView: some View {
    List($viewModel.records, id: \.self) { record in
      VStack(alignment: .leading, spacing: 16) {
        titleView(for: record)
        detailView(for: record)
      }
      .listRowBackground(Color.clear)
      .listRowSeparator(.hidden)
      .listRowInsets(.init(top: 16, leading: 8, bottom: 0, trailing: 8))
    }
    .listStyle(.plain)
    .scrollContentBackground(.hidden)
    .background(Color(.systemBackground))
  }
  
  @ViewBuilder
  private func titleView(for record: Binding<WeatherItem>) -> some View {
    HStack(spacing: .zero) {
      Text(record.wrappedValue.title)
        .foregroundStyle(Color(.label))
        .frame(maxWidth: .infinity, alignment: .leading)
      
      Button {
        updateCollasped(for: record)
      } label: {
        Image(systemName: record.wrappedValue.icon)
          .foregroundStyle(.secondary)
      }
    }
    .padding(.horizontal, 16)
    .contentShape(.rect)
    .onTapGesture {
      updateCollasped(for: record)
    }
  }
  
  @ViewBuilder
  private func detailView(for record: Binding<WeatherItem>) -> some View {
    if record.wrappedValue.isCollapsed {
      ScrollView(.horizontal) {
        hourlyRowView(for: record)
      }
      .scrollIndicators(.hidden)
    }
  }
  
  private func hourlyRowView(for record: Binding<WeatherItem>) -> some View {
    HStack(spacing: 12) {
      ForEach(record.wrappedValue.rows, id: \.self) { row in
        
        WeatherRowView(.mix(time: row.time, icon: row.icon, temperature: row.temperature))
          .isSelected(row.isSelected)
          .iconColor(row.isSelected ? .primary : .secondary)
          .backgroundColor( Color(row.isSelected ? .systemBackground: .secondarySystemBackground))
      }
    }
  }
  
  private func updateCollasped(for record: Binding<WeatherItem>) {
    withAnimation(.smooth) {
      record.wrappedValue.isCollapsed.toggle()
    }
  }
  
  // MARK: - Current Weather
  
  @ViewBuilder
  private func headerView() -> some View {
    if let currentWeather = viewModel.currentWeather {
      VStack(spacing: 16) {
        iconView(for: currentWeather.icon)
        tempeature(for: currentWeather)
        
        Divider()
      }
      .padding(.top, 24)
      .background(Color(.systemBackground))
    }
  }
  
  private func iconView(for icon: String) -> some View {
    Image(systemName: icon)
      .renderingMode(.template)
      .resizable()
      .frame(width: 48, height: 48)
      .foregroundStyle(Color.blue)
  }
  
  private func tempeature(for weather: CurrentWeatherItem) -> some View {
    VStack(spacing: 4) {
      Text(weather.temperature)
        .foregroundStyle(Color.primary)
      
      Text(weather.condition)
        .foregroundStyle(Color.secondary)
    }
    .frame(maxWidth: .infinity)
  }
}
