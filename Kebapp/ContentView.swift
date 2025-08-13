//
//  ContentView.swift
//  KebabCalculator
//
//  Created by Илья Варфоломеев on 31.05.2024.
//

import SwiftUI

/// Root view of the application showing all input forms and results.
struct ContentView: View {

    /// Portion settings shared with calculator and settings screen.
    @StateObject private var settings: SettingsViewModel
    /// Main view model used across subviews.
    @StateObject private var viewModel: CalculatorViewModel
    /// View model providing shareable text.
    @StateObject private var shareViewModel = ShareViewModel()
    /// History view model coming from environment.
    @EnvironmentObject private var historyViewModel: HistoryViewModel

    init() {
        let settingsVM = SettingsViewModel()
        _settings = StateObject(wrappedValue: settingsVM)
        _viewModel = StateObject(wrappedValue: CalculatorViewModel(settings: settingsVM))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                PeopleCountView(viewModel: viewModel)
                DurationTimeView(viewModel: viewModel)
                MeatTypeView(viewModel: viewModel)
                ResultView(viewModel: viewModel)
                ShareView(viewModel: shareViewModel)
            }
            .padding()
            .scrollContentBackground(.hidden)
            .background(Theme.cardBackground)
            .navigationTitle("Калькулятор")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView(viewModel: settings)) {
                        Image(systemName: "gear")
                    }
                    NavigationLink(destination: HistoryView(calculatorViewModel: viewModel)) {
                        Image(systemName: "clock")
                    }
                }
            }
        }
        .background(Theme.cardBackground)
    }
}

#Preview {
    ContentView()
}
