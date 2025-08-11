//
//  PeopleCountView.swift
//  KebabCalculator
//
//  Created by Илья Варфоломеев on 03.06.2024.
//

import SwiftUI

struct PeopleCountView: View {
    
    @State private var peopleCount: Int = 0
    @State private var vegaCount: Int = 0
    @State private var childrenCount: Int = 0
    
    var body: some View {
        CardContainer {
            VStack(alignment: .leading) {

                Text("Сколько будет гостей")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)

                Spacer(minLength: 16)

                Text("Взрослых")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextField("0", value: $peopleCount, format: .number)
                    .foregroundStyle(.secondary)
                    .border(.red)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)

                Spacer(minLength: 16)

                Text("Из них не ест мясо")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextField("0", value: $vegaCount, format: .number)
                    .foregroundStyle(.secondary)
                    .border(.red)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)

                Spacer(minLength: 16)

                Text("Детей")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextField("0", value: $childrenCount, format: .number)
                    .foregroundStyle(.secondary)
                    .border(.red)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)

            }
        }
    }
}

#Preview {
    PeopleCountView()
}
