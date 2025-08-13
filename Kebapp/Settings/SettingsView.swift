import SwiftUI

/// Screen allowing user to adjust portion sizes for adults and children.
struct SettingsView: View {
    /// Shared settings view model.
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        ScrollView {
            CardContainer {
                Text("Настройки порций")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                Spacer(minLength: 16)

                Group {
                    stepperRow(title: "Порция взрослого на пару часов", value: $viewModel.coupleHoursPortion, step: 50, range: 200...2000)
                    stepperRow(title: "Порция взрослого на день", value: $viewModel.wholeDayPortion, step: 50, range: 200...3000)
                    stepperRow(title: "Порция взрослого на два дня", value: $viewModel.twoDaysPortion, step: 50, range: 200...5000)

                    VStack(alignment: .leading) {
                        Text("Коэффициент для ребёнка: \(viewModel.childCoefficient, specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Slider(value: $viewModel.childCoefficient, in: 0.3...0.8, step: 0.05)
                            .tint(Theme.accent)
                    }
                    .padding(.top, 8)
                }

                Button("Сбросить по умолчанию") {
                    viewModel.reset()
                }
                .padding(.top, 24)
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .scrollContentBackground(.hidden)
        .background(Theme.cardBackground)
        .navigationTitle("Настройки")
    }

    @ViewBuilder
    private func stepperRow(title: String, value: Binding<Double>, step: Double, range: ClosedRange<Double>) -> some View {
        VStack(alignment: .leading) {
            Text("\(title): \(Int(value.wrappedValue)) г")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Stepper("", value: value, in: range, step: step)
            .tint(Theme.accent)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel())
}

