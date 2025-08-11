//
//  PeopleCountView.swift
//  KebabCalculator
//
//  Created by Илья Варфоломеев on 03.06.2024.
//

import SwiftUI

struct PeopleCountView: View {
    
    @State private var peopleCountField: String = ""
    @State private var vegaCountField: String = ""
    @State private var childrenCountField: String = ""
    
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

                TextField("0", text: $peopleCountField)
                    .foregroundStyle(.secondary)
                    .border(.red)
                    .multilineTextAlignment(.center)

                Spacer(minLength: 16)

                Text("Из них не ест мясо")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextField("0", text: $vegaCountField)
                    .foregroundStyle(.secondary)
                    .border(.red)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)

                Spacer(minLength: 16)

                Text("Детей")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextField("0", text: $childrenCountField)
                    .foregroundStyle(.secondary)
                    .border(.red)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)

            }
        }
    }
}

#Preview {
    PeopleCountView()
}
