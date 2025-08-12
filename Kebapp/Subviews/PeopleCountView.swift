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

            Text("Взрослых")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField("0", value: adultBinding, format: .number)
                .multilineTextAlignment(.center)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)

            Spacer(minLength: 16)

            Text("Из них не ест мясо")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField("0", value: vegetarianBinding, format: .number)
                .multilineTextAlignment(.center)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)

            if viewModel.data.vegetarianAdults > viewModel.data.adultGuests {
                Text("Не может быть больше, чем взрослых")
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Spacer(minLength: 16)

            Text("Детей")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField("0", value: childrenBinding, format: .number)
                .multilineTextAlignment(.center)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)

        }
    }

    // MARK: - Bindings

    /// Binding for adult guests count that prevents negative values.
    private var adultBinding: Binding<Int> {
        Binding(
            get: { viewModel.data.adultGuests },
            set: { viewModel.data.adultGuests = max(0, $0) }
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
