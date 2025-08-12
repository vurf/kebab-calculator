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

    var body: some View {
        ScrollView {
            PeopleCountView(viewModel: viewModel)
            DurationTimeView(viewModel: viewModel)
            MeatTypeView(viewModel: viewModel)
            ResultView(viewModel: viewModel)

            // MARK: - Future Scope
            // TODO: Сохранение истории расчётов
            // TODO: Шаринг результатов
            // TODO: Добавить гарниры
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
