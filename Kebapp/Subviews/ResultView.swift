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
    /// History view model used for saving calculations.
    @EnvironmentObject var historyViewModel: HistoryViewModel

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
                        Text(String(format: "%.2f кг", viewModel.totalWeight))
                    }

                    ForEach(Array(viewModel.distribution.keys), id: \.self) { meat in
                        if let weight = viewModel.distribution[meat] {
                            HStack {
                                Text(meat.rawValue)
                                Spacer()
                                Text("\(weight, specifier: "%.2f") кг")
                            }
                        }
                    }

                    HStack {
                        Text("На человека")
                        Spacer()
                        Text("\(viewModel.portionPerPerson, specifier: "%.2f") кг")
                    }

                    Button("Сохранить расчёт") {
                        let item = CalculationHistoryItem(
                            id: UUID(),
                            date: Date(),
                            adults: viewModel.data.adultGuests,
                            nonMeatEaters: viewModel.data.vegetarianAdults,
                            kids: viewModel.data.children,
                            duration: viewModel.data.duration.title,
                            meat: viewModel.distribution.reduce(into: [:]) { $0[$1.key.rawValue] = $1.value },
                            totalWeight: viewModel.totalWeight,
                            portionPerPerson: viewModel.portionPerPerson
                        )
                        historyViewModel.save(item: item)
                    }
                    .buttonStyle(.bordered)
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
