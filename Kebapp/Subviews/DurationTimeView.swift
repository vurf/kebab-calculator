//
//  DurationTimeView.swift
//  KebabCalculator
//
//  Created by Илья Варфоломеев on 03.06.2024.
//

import SwiftUI

/// View for choosing event duration.
struct DurationTimeView: View {

    /// Shared view model with user input and calculations.
    @ObservedObject var viewModel: CalculatorViewModel

    var body: some View {
        CardContainer {
            Text("Сколько собираетесь тусить")
                .font(.title2.bold())
                .foregroundStyle(.primary)

            Spacer(minLength: 16)

            Picker("Сколько собираетесь тусить", selection: $viewModel.data.duration) {
                ForEach(Duration.allCases) { duration in
                    Text(duration.title).tag(duration)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

#Preview {
    DurationTimeView(viewModel: CalculatorViewModel())
}
