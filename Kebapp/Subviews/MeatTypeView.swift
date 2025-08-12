//
//  MeatTypeView.swift
//  KebabCalculator
//
//  Created by Илья Варфоломеев on 03.06.2024.
//

import SwiftUI

/// View for choosing meat types.
struct MeatTypeView: View {

    /// Shared view model with user input and calculations.
    @ObservedObject var viewModel: CalculatorViewModel

    var body: some View {
        CardContainer {
            Text("Какое мясо будете жарить")
                .font(.title2.bold())
                .foregroundStyle(.primary)

            Spacer(minLength: 16)

            HStack {
                VStack(alignment: .leading) {
                    Toggle(Meat.pork.rawValue, isOn: binding(for: .pork))
                        .toggleStyle(CheckboxToggleStyle())

                    Toggle(Meat.beef.rawValue, isOn: binding(for: .beef))
                        .toggleStyle(CheckboxToggleStyle())
                }
                Spacer()
                VStack(alignment: .leading) {
                    Toggle(Meat.chicken.rawValue, isOn: binding(for: .chicken))
                        .toggleStyle(CheckboxToggleStyle())

                    Toggle(Meat.lamb.rawValue, isOn: binding(for: .lamb))
                        .toggleStyle(CheckboxToggleStyle())
                }
                Spacer()
            }

            if viewModel.data.selectedMeats.isEmpty {
                Text("Выберите хотя бы один вид мяса")
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
    }

    /// Returns binding for meat selection handling insertion and removal from set.
    private func binding(for meat: Meat) -> Binding<Bool> {
        Binding(
            get: { viewModel.data.selectedMeats.contains(meat) },
            set: { isOn in
                if isOn {
                    viewModel.data.selectedMeats.insert(meat)
                } else {
                    viewModel.data.selectedMeats.remove(meat)
                }
            }
        )
    }
}

#Preview {
    MeatTypeView(viewModel: CalculatorViewModel())
}
