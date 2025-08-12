//
//  MeatTypeView.swift
//  KebabCalculator
//
//  Created by Илья Варфоломеев on 03.06.2024.
//

import SwiftUI

struct MeatTypeView: View {
    
    @State private var isPork: Bool = true
    @State private var isBeef: Bool = false
    @State private var isChicken: Bool = false
    @State private var isLamb: Bool = false

    var body: some View {
        CardContainer {
            Text("Какое мясо будете жарить")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)

            Spacer(minLength: 16)

            HStack {
                VStack(alignment: .leading) {
                    Toggle("Свинина", isOn: $isPork)
                        .toggleStyle(CheckboxToggleStyle())

                    Toggle("Говядина", isOn: $isBeef)
                        .toggleStyle(CheckboxToggleStyle())
                }
                Spacer()
                VStack(alignment: .leading) {
                    Toggle("Курица", isOn: $isChicken)
                        .toggleStyle(CheckboxToggleStyle())

                    Toggle("Баранина", isOn: $isLamb)
                        .toggleStyle(CheckboxToggleStyle())
                }
                Spacer()
            }
        }
    }
}

#Preview {
    MeatTypeView()
}
