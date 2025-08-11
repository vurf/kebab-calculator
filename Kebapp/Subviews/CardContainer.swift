//
//  CardContainer.swift
//  KebabCalculator
//
//  Created by ChatGPT on 2024-06-04.
//
import SwiftUI

/// A convenience container that applies the app's standard card styling.
///
/// Wrap views in `CardContainer` when they should share the common
/// padding, mint background, and rounded-corner appearance used for
/// card-like elements throughout the app. Use regular SwiftUI containers
/// such as `VStack` or `HStack` directly when this styling is not needed
/// or when a custom look is required.
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
