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
        .background(Color.mint.opacity(0.2))
        .clipShape(.rect(cornerRadius: 18))
    }
}

#Preview {
    CardContainer {
        Text("Preview")
    }
}
