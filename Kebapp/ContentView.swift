//
//  ContentView.swift
//  KebabCalculator
//
//  Created by Илья Варфоломеев on 31.05.2024.
//

import SwiftUI

/// Root view of the application showing all input forms and results.
struct ContentView: View {

    /// Main view model used across subviews.
    @StateObject private var viewModel = CalculatorViewModel()
    /// View model providing shareable text.
    @StateObject private var shareViewModel = ShareViewModel()
    /// History view model coming from environment.
    @EnvironmentObject private var historyViewModel: HistoryViewModel

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
            .navigationTitle("Калькулятор")
            .toolbar {
                NavigationLink(destination: HistoryView(calculatorViewModel: viewModel)) {
                    Image(systemName: "clock")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
