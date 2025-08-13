import SwiftUI

/// Screen showing detailed calculation information.
struct HistoryDetailView: View {
    let item: CalculationHistoryItem
    @ObservedObject var calculatorViewModel: CalculatorViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(item.date, style: .date)
                    .font(.title2.bold())

                Group {
                    detailRow(title: "Взрослые", value: "\(item.adults)")
                    detailRow(title: "Не едят мясо", value: "\(item.nonMeatEaters)")
                    detailRow(title: "Дети", value: "\(item.kids)")
                    detailRow(title: "Длительность", value: item.duration)
                }

                Text("Мясо")
                    .font(.headline)
                ForEach(item.meat.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                    detailRow(title: key, value: String(format: "%.2f кг", value))
                }

                detailRow(title: "Общий вес", value: String(format: "%.2f кг", item.totalWeight))
                detailRow(title: "На человека", value: String(format: "%.2f кг", item.portionPerPerson))

                Button("Использовать снова") {
                    reuse()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Детали")
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
        }
    }

    private func reuse() {
        calculatorViewModel.data.adultGuests = item.adults
        calculatorViewModel.data.vegetarianAdults = item.nonMeatEaters
        calculatorViewModel.data.children = item.kids
        if let duration = Duration.allCases.first(where: { $0.title == item.duration }) {
            calculatorViewModel.data.duration = duration
        }
        let meats = item.meat.keys.compactMap { Meat(rawValue: $0) }
        calculatorViewModel.data.selectedMeats = Set(meats)
        dismiss()
    }
}

#Preview {
    HistoryDetailView(item: CalculationHistoryItem(id: UUID(), date: .now, adults: 2, nonMeatEaters: 0, kids: 1, duration: "Пару часов", meat: ["Свинина":1], totalWeight: 1, portionPerPerson: 0.5), calculatorViewModel: CalculatorViewModel())
}
