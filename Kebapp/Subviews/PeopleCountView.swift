//
//  PeopleCountView.swift
//  KebabCalculator
//
//  Created by Илья Варфоломеев on 03.06.2024.
//

import SwiftUI

/// View with text fields to enter guests information.
struct PeopleCountView: View {

    /// Shared view model with user input and calculations.
    @ObservedObject var viewModel: CalculatorViewModel

    var body: some View {
        CardContainer {

            Text("Сколько будет гостей")
                .font(.title2.bold())
                .foregroundStyle(.primary)

            Spacer(minLength: 16)

            Text("Взрослых: \(viewModel.data.adultGuests)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Stepper("", value: adultBinding, in: 0...100)
                .tint(Theme.accent)

            Spacer(minLength: 16)

            Text("Из них не ест мясо: \(viewModel.data.vegetarianAdults)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Stepper("", value: vegetarianBinding, in: 0...viewModel.data.adultGuests)
                .tint(Theme.accent)

            Spacer(minLength: 16)

            Text("Детей: \(viewModel.data.children)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Stepper("", value: childrenBinding, in: 0...100)
                .tint(Theme.accent)

        }
    }

    // MARK: - Bindings

    /// Binding for adult guests count that prevents negative values.
    private var adultBinding: Binding<Int> {
        Binding(
            get: { viewModel.data.adultGuests },
            set: {
                viewModel.data.adultGuests = max(0, $0)
                if viewModel.data.vegetarianAdults > viewModel.data.adultGuests {
                    viewModel.data.vegetarianAdults = viewModel.data.adultGuests
                }
            }
        )
    }

    /// Binding for vegetarian adults count that prevents negative values.
    private var vegetarianBinding: Binding<Int> {
        Binding(
            get: { viewModel.data.vegetarianAdults },
            set: { viewModel.data.vegetarianAdults = max(0, $0) }
        )
    }

    /// Binding for children count that prevents negative values.
    private var childrenBinding: Binding<Int> {
        Binding(
            get: { viewModel.data.children },
            set: { viewModel.data.children = max(0, $0) }
        )
    }
}

#Preview {
    PeopleCountView(viewModel: CalculatorViewModel())
}
