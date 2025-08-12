//
//  CardContainer.swift
//  KebabCalculator
//
//  Created by OpenAI on 2024-06-XX.
//

import SwiftUI

struct CardContainer<Content: View>: View {
    private let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading) {
            content()
        }
        .padding()
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Theme.accent.opacity(0.15))
        )
    }
}

#Preview {
    CardContainer {
        Text("Preview")
    }
}
