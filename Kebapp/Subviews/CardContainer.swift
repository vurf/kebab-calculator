//
//  CardContainer.swift
//  KebabCalculator
//
//  Created by ChatGPT on 2024-06-04.
//
import SwiftUI

struct CardContainer<Content: View>: View {
    @ViewBuilder var content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .padding()
            .background(Color.mint.opacity(0.2))
            .clipShape(.rect(cornerRadius: 18))
    }
}

#Preview {
    CardContainer {
        VStack {
            Text("Preview")
        }
    }
}
