import Foundation
import Combine

/// ViewModel storing user-adjustable portion settings.
/// Values are persisted in `UserDefaults` and published so that
/// any dependant views or models update reactively.
final class SettingsViewModel: ObservableObject {
    // MARK: - Keys
    private enum Keys {
        static let coupleHours = "portion.coupleHours"
        static let wholeDay = "portion.wholeDay"
        static let twoDays = "portion.twoDays"
        static let childCoef = "portion.childCoef"
    }

    // MARK: - Defaults
    private enum Defaults {
        static let coupleHours: Double = 400 // grams
        static let wholeDay: Double = 700    // grams
        static let twoDays: Double = 1000    // grams
        static let childCoef: Double = 0.5   // 50%
    }

    private let storage: UserDefaults

    // MARK: - Published settings
    @Published var coupleHoursPortion: Double {
        didSet { storage.set(coupleHoursPortion, forKey: Keys.coupleHours) }
    }
    @Published var wholeDayPortion: Double {
        didSet { storage.set(wholeDayPortion, forKey: Keys.wholeDay) }
    }
    @Published var twoDaysPortion: Double {
        didSet { storage.set(twoDaysPortion, forKey: Keys.twoDays) }
    }
    @Published var childCoefficient: Double {
        didSet { storage.set(childCoefficient, forKey: Keys.childCoef) }
    }

    // MARK: - Init
    init(storage: UserDefaults = .standard) {
        self.storage = storage

        let ch = storage.double(forKey: Keys.coupleHours)
        let wd = storage.double(forKey: Keys.wholeDay)
        let td = storage.double(forKey: Keys.twoDays)
        let coef = storage.double(forKey: Keys.childCoef)

        coupleHoursPortion = ch == 0 ? Defaults.coupleHours : ch
        wholeDayPortion = wd == 0 ? Defaults.wholeDay : wd
        twoDaysPortion = td == 0 ? Defaults.twoDays : td
        childCoefficient = coef == 0 ? Defaults.childCoef : coef
    }

    /// Resets all values to defaults and saves them to `UserDefaults`.
    func reset() {
        coupleHoursPortion = Defaults.coupleHours
        wholeDayPortion = Defaults.wholeDay
        twoDaysPortion = Defaults.twoDays
        childCoefficient = Defaults.childCoef
    }
}

