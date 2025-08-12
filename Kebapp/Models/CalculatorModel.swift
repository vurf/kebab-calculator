import Foundation

/// Represents duration of the barbecue event.
enum Duration: Int, CaseIterable, Identifiable {
    case coupleHours
    case wholeDay
    case twoDays

    var id: Int { rawValue }

    /// Display title used in UI.
    var title: String {
        switch self {
        case .coupleHours: return "Пару часов"
        case .wholeDay: return "Весь день"
        case .twoDays: return "Два дня"
        }
    }

    /// Coefficient applied to the base adult portion.
    var coefficient: Double {
        switch self {
        case .coupleHours: return 1.0
        case .wholeDay: return 1.75
        case .twoDays: return 2.5
        }
    }
}

/// Types of meat available for selection.
enum Meat: String, CaseIterable, Identifiable {
    case pork = "Свинина"
    case beef = "Говядина"
    case chicken = "Курица"
    case lamb = "Баранина"

    var id: String { rawValue }
}

/// Data model storing user input values for calculation.
struct CalculatorData {
    var adultGuests: Int = 0
    var vegetarianAdults: Int = 0
    var children: Int = 0
    var duration: Duration = .coupleHours
    var selectedMeats: Set<Meat> = [.pork]
}
