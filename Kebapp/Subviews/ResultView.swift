//
//  ResultView.swift
//  Kebapp
//
//  Created by OpenAI on 2024-06-XX.
//

import SwiftUI

/// View displaying calculation results.
struct ResultView: View {

    /// Shared view model with user input and calculations.
    @ObservedObject var viewModel: CalculatorViewModel

    var body: some View {
        CardContainer {
            Text("Результат")
                .font(.title2.bold())
                .foregroundStyle(.primary)

            Spacer(minLength: 16)

            if viewModel.isValid {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Общий вес")
                        Spacer()
                        Text("\(viewModel.totalWeight, specifier: \"%.2f\") кг")
                    }

                    ForEach(Array(viewModel.distribution.keys), id: \.self) { meat in
                        if let weight = viewModel.distribution[meat] {
                            HStack {
                                Text(meat.rawValue)
                                Spacer()
                                Text("\(weight, specifier: \"%.2f\") кг")
                            }
                        }
                    }

                    HStack {
                        Text("На человека")
                        Spacer()
                        Text("\(viewModel.portionPerPerson, specifier: \"%.2f\") кг")
                    }
                }
            } else {
                Text("Заполните все поля корректно")
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
    }
}

#Preview {
    ResultView(viewModel: CalculatorViewModel())
}
