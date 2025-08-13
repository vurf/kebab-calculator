import Foundation
import Combine

/// ViewModel responsible for meat calculation logic and validation.
final class CalculatorViewModel: ObservableObject {
    @Published var data = CalculatorData()

    private let settings: SettingsViewModel
    private var cancellables = Set<AnyCancellable>()

    init(settings: SettingsViewModel = SettingsViewModel()) {
        self.settings = settings
        // Propagate changes from settings to refresh computed properties
        settings.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    /// Portion for one adult depending on the selected duration.
    var adultPortion: Double {
        switch data.duration {
        case .coupleHours:
            return settings.coupleHoursPortion / 1000
        case .wholeDay:
            return settings.wholeDayPortion / 1000
        case .twoDays:
            return settings.twoDaysPortion / 1000
        }
    }

    /// Portion for one child.
    var childPortion: Double { adultPortion * settings.childCoefficient }

    /// Total required meat weight in kilograms.
    var totalWeight: Double {
        let adults = max(data.adultGuests - data.vegetarianAdults, 0)
        let kids = max(data.children, 0)
        return (Double(adults) * adultPortion) + (Double(kids) * childPortion)
    }

    /// Portion per person (only those who eat meat).
    var portionPerPerson: Double {
        let eaters = max(data.adultGuests - data.vegetarianAdults, 0) + data.children
        guard eaters > 0 else { return 0 }
        return totalWeight / Double(eaters)
    }

    /// Distribution of meat weight across selected meat types.
    var distribution: [Meat: Double] {
        guard !data.selectedMeats.isEmpty else { return [:] }
        let share = totalWeight / Double(data.selectedMeats.count)
        var result: [Meat: Double] = [:]
        data.selectedMeats.forEach { result[$0] = share }
        return result
    }

    /// Validation for input data.
    var isValid: Bool {
        data.adultGuests >= data.vegetarianAdults && !data.selectedMeats.isEmpty
    }
}
