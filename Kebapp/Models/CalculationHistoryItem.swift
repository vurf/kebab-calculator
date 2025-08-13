import Foundation

/// Model representing a stored calculation result.
struct CalculationHistoryItem: Identifiable {
    var id: UUID
    var date: Date
    var adults: Int
    var nonMeatEaters: Int
    var kids: Int
    var duration: String
    var meat: [String: Double]
    var totalWeight: Double
    var portionPerPerson: Double
}

extension CalculationHistoryItem {
    /// Creates a model from a managed object.
    init(entity: CalculationEntity) {
        self.id = entity.id
        self.date = entity.date
        self.adults = Int(entity.adults)
        self.nonMeatEaters = Int(entity.nonMeatEaters)
        self.kids = Int(entity.kids)
        self.duration = entity.duration
        let meatDict = (try? JSONDecoder().decode([String: Double].self, from: entity.meat)) ?? [:]
        self.meat = meatDict
        self.totalWeight = entity.totalWeight
        self.portionPerPerson = entity.portionPerPerson
    }
}
