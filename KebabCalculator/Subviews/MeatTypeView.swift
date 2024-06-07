//
//  MeatTypeView.swift
//  KebabCalculator
//
//  Created by Илья Варфоломеев on 03.06.2024.
//

import SwiftUI

struct MeatTypeView: View {
    
    @State private var svinina: Bool = true
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Какое мясо будете жарить")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)
                
            Spacer(minLength: 16)
            
            HStack {
                VStack(alignment: .leading) {
                    Toggle("Свинина", isOn: $svinina)
                        .toggleStyle(CheckboxToggleStyle())
                    
                    Toggle("Говядина", isOn: $svinina)
                        .toggleStyle(CheckboxToggleStyle())
                }
                Spacer()
                VStack(alignment: .leading) {
                    Toggle("Курица", isOn: $svinina)
                        .toggleStyle(CheckboxToggleStyle())
                    
                    Toggle("Баранина", isOn: $svinina)
                        .toggleStyle(CheckboxToggleStyle())
                }
                Spacer()
            }
        }
        .padding()
        .background(Color.mint.opacity(0.2))
        .clipShape(.rect(cornerRadius: 18))
    }
}

#Preview {
    MeatTypeView()
}
