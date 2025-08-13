import SwiftUI

/// Reusable button style for share buttons.
struct ShareButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(red: 1.0, green: 122/255, blue: 0))
            .foregroundColor(.white)
            .cornerRadius(8)
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}
