import UIKit

// MARK: - Design Tokens
enum DS {

    // MARK: Colors
    enum Colors {
        static let ember      = UIColor(hex: "FF6A1A")
        static let emberHot   = UIColor(hex: "FFB02E")
        static let emberDeep  = UIColor(hex: "E8420E")
        static let emberSoft  = UIColor(hex: "FF8A47")
        // Dark background
        static let bg0        = UIColor(hex: "0C0A09")
        static let bg1        = UIColor(hex: "141019")
        static let bgGradA    = UIColor(hex: "1A1310")
        static let bgGradB    = UIColor(hex: "0B0908")
        // Card / surface
        static let card       = UIColor(hex: "1C1714")
        static let cardHi     = UIColor(hex: "241D18")
        // Metal
        static let metalA     = UIColor(hex: "3A332E")
        static let metalB     = UIColor(hex: "181410")
        // Text
        static let txt        = UIColor(hex: "F6EFE6")
        static let txt2       = UIColor(hex: "B7ADA2")
        static let txt3       = UIColor(hex: "7E756C")
        // Lines / chips
        static let line       = UIColor(white: 1, alpha: 0.08)
        static let lineStrong = UIColor(white: 1, alpha: 0.14)
        static let chip       = UIColor(white: 1, alpha: 0.06)
        static let chipActive = UIColor(hex: "FF6A1A").withAlphaComponent(0.16)
    }

    // MARK: Fonts
    enum Fonts {
        static var hero:       UIFont { .systemFont(ofSize: 40, weight: .heavy) }
        static var h1:         UIFont { .systemFont(ofSize: 30, weight: .heavy) }
        static var h2:         UIFont { .systemFont(ofSize: 23, weight: .bold) }
        static var body:       UIFont { .systemFont(ofSize: 17, weight: .medium) }
        static var caption:    UIFont { .systemFont(ofSize: 14, weight: .semibold) }
        static var kicker:     UIFont { .systemFont(ofSize: 13, weight: .bold) }
        static var statVal:    UIFont { .monospacedDigitSystemFont(ofSize: 26, weight: .heavy) }
        static var bigNum:     UIFont { .monospacedDigitSystemFont(ofSize: 56, weight: .heavy) }
        static var stepNum:    UIFont { .monospacedDigitSystemFont(ofSize: 96, weight: .heavy) }
    }

    // MARK: Layout
    static let pad:        CGFloat = 22
    static let cardRadius: CGFloat = 30
    static let btnHeight:  CGFloat = 64
    static let btnRadius:  CGFloat = 22
}

// MARK: - UIColor hex
extension UIColor {
    convenience init(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespaces)
        if s.hasPrefix("#") { s = String(s.dropFirst()) }
        if s.count == 3 { s = s.map { "\($0)\($0)" }.joined() }
        var n: UInt64 = 0
        Scanner(string: s).scanHexInt64(&n)
        self.init(
            red:   CGFloat((n >> 16) & 0xFF) / 255,
            green: CGFloat((n >>  8) & 0xFF) / 255,
            blue:  CGFloat( n        & 0xFF) / 255,
            alpha: 1
        )
    }
}

// MARK: - EmberButton (primary fire CTA)
final class EmberButton: UIControl {
    private let label = UILabel()
    private let baseGrad  = CAGradientLayer()
    private let shineGrad = CAGradientLayer()

    override init(frame: CGRect) { super.init(frame: frame); build() }
    required init?(coder: NSCoder) { fatalError() }

    func setTitle(_ t: String, for _: UIControl.State = .normal) { label.text = t }

    private func build() {
        layer.cornerRadius = DS.btnRadius
        clipsToBounds      = false

        baseGrad.colors    = [DS.Colors.emberHot.cgColor,
                              DS.Colors.ember.cgColor,
                              DS.Colors.emberDeep.cgColor]
        baseGrad.locations = [0, 0.52, 1]
        baseGrad.cornerRadius = DS.btnRadius
        layer.insertSublayer(baseGrad, at: 0)

        shineGrad.colors     = [UIColor.clear.cgColor,
                                UIColor(white: 1, alpha: 0.35).cgColor,
                                UIColor.clear.cgColor]
        shineGrad.startPoint = CGPoint(x: 0, y: 0.5)
        shineGrad.endPoint   = CGPoint(x: 1, y: 0.5)
        shineGrad.cornerRadius = DS.btnRadius
        layer.addSublayer(shineGrad)

        label.font          = .systemFont(ofSize: 20, weight: .bold)
        label.textColor     = UIColor(hex: "1A0E05")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        layer.shadowColor   = DS.Colors.emberDeep.cgColor
        layer.shadowOffset  = CGSize(width: 0, height: 12)
        layer.shadowRadius  = 24
        layer.shadowOpacity = 0.42

        addTarget(self, action: #selector(dn), for: .touchDown)
        addTarget(self, action: #selector(up), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        startShine()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        baseGrad.frame  = bounds
        shineGrad.frame = bounds
    }

    private func startShine() {
        let a          = CABasicAnimation(keyPath: "locations")
        a.fromValue    = [-0.5, -0.3, -0.1] as [NSNumber]
        a.toValue      = [ 1.1,  1.3,  1.5] as [NSNumber]
        a.duration     = 2.6
        a.repeatCount  = .infinity
        a.beginTime    = CACurrentMediaTime() + 0.6
        shineGrad.add(a, forKey: "shine")
    }

    @objc private func dn() {
        UIView.animate(withDuration: 0.12) { self.transform = .init(scaleX: 0.96, y: 0.96) }
    }
    @objc private func up() {
        UIView.animate(withDuration: 0.3, delay: 0,
                       usingSpringWithDamping: 0.5, initialSpringVelocity: 1) {
            self.transform = .identity
        }
    }
}

// MARK: - GhostButton
final class GhostButton: UIControl {
    private let label = UILabel()
    init(title: String) {
        super.init(frame: .zero)
        label.text          = title
        label.font          = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor     = DS.Colors.txt
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        layer.cornerRadius  = 18
        layer.borderWidth   = 1
        layer.borderColor   = DS.Colors.line.cgColor
        backgroundColor     = DS.Colors.chip
        addTarget(self, action: #selector(dn), for: .touchDown)
        addTarget(self, action: #selector(up), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    required init?(coder: NSCoder) { fatalError() }
    func setTitle(_ t: String) { label.text = t }
    @objc private func dn() { UIView.animate(withDuration: 0.12) { self.transform = .init(scaleX: 0.96, y: 0.96) } }
    @objc private func up() {
        UIView.animate(withDuration: 0.3, delay: 0,
                       usingSpringWithDamping: 0.5, initialSpringVelocity: 1) { self.transform = .identity }
    }
}

// MARK: - KickerLabel
final class KickerLabel: UILabel {
    init(_ text: String = "") {
        super.init(frame: .zero)
        self.text      = text
        font           = DS.Fonts.kicker
        textColor      = DS.Colors.ember
        letterSpacing(0.18)
    }
    required init?(coder: NSCoder) { fatalError() }
    func letterSpacing(_ v: CGFloat) {
        let s = NSMutableAttributedString(string: text ?? "")
        s.addAttribute(.kern, value: v * (font.pointSize), range: NSRange(location: 0, length: s.length))
        attributedText = s
    }
}

// MARK: - ProgressDots
final class ProgressDotsView: UIView {
    private var dots: [UIView] = []
    private var total = 0

    func configure(total: Int) {
        self.total = total
        dots.forEach { $0.removeFromSuperview() }
        dots = (0..<total).map { _ in
            let v = UIView()
            v.backgroundColor = DS.Colors.lineStrong
            v.layer.cornerRadius = 3.5
            return v
        }
        let stack = UIStackView(arrangedSubviews: dots)
        stack.axis    = .horizontal
        stack.spacing = 7
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    func update(current: Int) {
        UIView.animate(withDuration: 0.35,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.5) {
            for (i, dot) in self.dots.enumerated() {
                if i < current {
                    dot.backgroundColor = DS.Colors.ember
                    dot.layer.cornerRadius = 3.5
                    dot.widthConstraint?.constant = 7
                } else if i == current {
                    dot.backgroundColor = DS.Colors.ember
                    dot.layer.cornerRadius = 5
                    dot.widthConstraint?.constant = 22
                } else {
                    dot.backgroundColor = DS.Colors.lineStrong
                    dot.layer.cornerRadius = 3.5
                    dot.widthConstraint?.constant = 7
                }
            }
            self.layoutIfNeeded()
        }
    }
}

// We need a helper to get/set a width constraint by value:
extension UIView {
    var widthConstraint: NSLayoutConstraint? {
        constraints.first { $0.firstAttribute == .width && $0.secondItem == nil }
    }
}
