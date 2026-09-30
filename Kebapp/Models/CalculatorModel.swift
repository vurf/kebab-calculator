import Foundation

// MARK: - Domain enums

enum MeatType: String, CaseIterable, Codable {
    case pork, chicken, lamb, beef, mix

    var name: String {
        switch self {
        case .pork:    return "Свинина"
        case .chicken: return "Курица"
        case .lamb:    return "Баранина"
        case .beef:    return "Говядина"
        case .mix:     return "Микс"
        }
    }
    var emoji: String {
        switch self {
        case .pork:    return "\u{1F969}"   // 🥩
        case .chicken: return "\u{1F357}"   // 🍗
        case .lamb:    return "\u{1F356}"   // 🍖
        case .beef:    return "\u{1F969}"   // 🥩
        case .mix:     return "\u{1F525}"   // 🔥
        }
    }
    var note: String {
        switch self {
        case .pork:    return "Классика шашлыка"
        case .chicken: return "Лёгкое и быстрое"
        case .lamb:    return "По-кавказски"
        case .beef:    return "Сочно и сытно"
        case .mix:     return "Всего понемногу"
        }
    }
}

enum KidsOption: String, CaseIterable, Codable {
    case none, few, many

    var name: String   { ["Нет", "Немного", "Много"][rawIndex] }
    var emoji: String  { ["🙅", "🧒", "👨‍👩‍👧‍👦"][rawIndex] }
    var note: String   { ["Только взрослые", "Пара детей", "Целая компания детворы"][rawIndex] }
    var factor: Double { [0.0, 0.35, 0.6][rawIndex] }

    private var rawIndex: Int {
        switch self { case .none: return 0; case .few: return 1; case .many: return 2 }
    }
}

enum AlcoholOption: String, CaseIterable, Codable {
    case none, some, yes

    var name: String  { ["Нет", "Немного", "Конечно будет"][rawIndex] }
    var emoji: String { ["🚫", "🍷", "🍻"][rawIndex] }
    var note: String  { ["Безалкогольно", "По чуть-чуть", "Как полагается"][rawIndex] }
    var beer:  Double { [0.0, 0.5,  1.0][rawIndex] }
    var strong: Double { [0.0, 0.05, 0.15][rawIndex] }
    var soft:  Double { [0.7, 0.5,  0.4][rawIndex] }

    private var rawIndex: Int {
        switch self { case .none: return 0; case .some: return 1; case .yes: return 2 }
    }
}

enum AppetiteOption: String, CaseIterable, Codable {
    case light, normal, beast

    var name: String  { ["Лёгкий", "Обычный", "Очень голодные"][rawIndex] }
    var emoji: String { ["🥗", "🍖", "🔥"][rawIndex] }
    var note: String  { ["Поедим в меру", "Нормальный аппетит", "Будем сметать всё"][rawIndex] }
    var meatKg: Double { [0.25, 0.35, 0.50][rawIndex] }

    private var rawIndex: Int {
        switch self { case .light: return 0; case .normal: return 1; case .beast: return 2 }
    }
}

// MARK: - Question steps

enum QuestionStep: Int, CaseIterable {
    case count = 0, kids, alcohol, appetite, meat

    var title: String {
        ["Сколько вас будет?",
         "Будут дети?",
         "Будет алкоголь?",
         "Какой аппетит?",
         "Какое мясо?"][rawValue]
    }
    var subtitle: String {
        ["Считаем взрослых гостей",
         "Они едят меньше — учтём",
         "Прикинем напитки",
         "От этого зависит порция",
         "Выбери основу для шампуров"][rawValue]
    }
}

// MARK: - Inputs & Result

struct BBQInputs {
    var count:    Int            = 6
    var kids:     KidsOption     = .none
    var alcohol:  AlcoholOption  = .some
    var appetite: AppetiteOption = .normal
    var meats:    [MeatType]     = [.pork]
}

struct ShoppingItem {
    let icon:  String
    let label: String
    let value: Double
    let unit:  String
}

struct BBQResult {
    let meat:     Double
    let onion:    Double
    let charcoal: Double
    let veg:      Double
    let drinks:   Double
    let bread:    Int
    let sauce:    Double
    let skewers:  Int
    let eaters:   Double
}

// MARK: - Calculator

enum BBQCalculator {
    static func calculate(_ i: BBQInputs) -> BBQResult {
        let adults = Double(i.count)
        let eaters = adults * (1 + i.kids.factor)
        let meat   = round2(eaters * i.appetite.meatKg, step: 0.1)
        let onion  = round2(meat * 0.25,               step: 0.1)
        let veg    = round2(adults * 0.30 + adults * i.kids.factor * 0.15, step: 0.1)
        let charco = round2(meat * 1.45 + 1.0,         step: 0.5)
        let drinks = round2(adults * (i.alcohol.beer + i.alcohol.strong) + eaters * i.alcohol.soft, step: 0.5)
        let bread  = Int(ceil(eaters * 0.6))
        let sauce  = round2(eaters * 0.08, step: 0.05)
        let skew   = max(2, Int(ceil(meat / 0.35)))
        let ea     = (eaters * 10).rounded() / 10

        return BBQResult(meat: meat, onion: onion, charcoal: charco, veg: veg,
                         drinks: drinks, bread: bread, sauce: sauce,
                         skewers: skew, eaters: ea)
    }

    static func shoppingList(inputs: BBQInputs, result: BBQResult) -> [ShoppingItem] {
        [
            ShoppingItem(icon: "\u{1F356}", label: inputs.meats.map(\.name).joined(separator: " + "), value: result.meat, unit: "кг"),
            ShoppingItem(icon: "\u{1F9C5}", label: "Лук",            value: result.onion,   unit: "кг"),
            ShoppingItem(icon: "\u{1F525}", label: "Уголь",          value: result.charcoal,unit: "кг"),
            ShoppingItem(icon: "\u{1F957}", label: "Овощи и зелень", value: result.veg,     unit: "кг"),
            ShoppingItem(icon: "\u{1F964}", label: "Напитки",        value: result.drinks,  unit: "л"),
            ShoppingItem(icon: "\u{1FAD3}", label: "Лаваш",          value: Double(result.bread), unit: "шт"),
            ShoppingItem(icon: "\u{1F96B}", label: "Соусы",          value: result.sauce,   unit: "кг"),
        ]
    }

    private static func round2(_ v: Double, step: Double) -> Double {
        (v / step).rounded() * step
    }
}
