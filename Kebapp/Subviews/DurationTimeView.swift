//
//  DurationTimeView.swift
//  KebabCalculator
//
//  Created by Илья Варфоломеев on 03.06.2024.
//

import SwiftUI

struct DurationTimeView: View {
    
    @State private var durationTime: Int = 0

    var body: some View {
        CardContainer {
            Text("Сколько собираетесь тусить")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)

            Spacer(minLength: 16)

            Picker("Сколько собираетесь тусить", selection: $durationTime) {
                Text("Пару часов").tag(0)
                Text("Весь день").tag(1)
                Text("Два дня").tag(2)
            }.pickerStyle(.segmented)
        }
    }
}

#Preview {
    DurationTimeView()
}
