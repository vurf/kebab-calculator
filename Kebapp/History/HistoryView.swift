import SwiftUI

/// Screen displaying list of saved calculations.
struct HistoryView: View {
    @EnvironmentObject var historyViewModel: HistoryViewModel
    @ObservedObject var calculatorViewModel: CalculatorViewModel

    var body: some View {
        List {
            ForEach(historyViewModel.items) { item in
                NavigationLink(destination: HistoryDetailView(item: item, calculatorViewModel: calculatorViewModel)) {
                    HistoryRow(item: item)
                }
            }
            .onDelete(perform: historyViewModel.delete)
        }
        .listStyle(.plain)
        .navigationTitle("История")
    }
}

/// Row with custom styling.
struct HistoryRow: View {
    let item: CalculationHistoryItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.date, style: .date)
                .font(.headline)
            HStack {
                Text("Общий вес: \(item.totalWeight, specifier: "%.2f") кг")
                Spacer()
                Text("Мясо: \(item.meat.keys.count)")
            }
            .font(.subheadline)
        }
        .padding()
        .background(Color(hex: "FFF2E6"))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

private extension Color {
    /// Initialize Color from hex string like "FFF2E6".
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    HistoryView(calculatorViewModel: CalculatorViewModel())
        .environmentObject(HistoryViewModel())
}
