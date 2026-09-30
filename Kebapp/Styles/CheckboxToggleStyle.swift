import UIKit

// MARK: - Base swipe card

final class QuestionCardView: UIView {

    // MARK: Public
    var onAdvance: (() -> Void)?

    // MARK: Private
    private var dragX:     CGFloat = 0
    private var isDragging = false
    private var startX:    CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildCard()
        addPan()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func buildCard() {
        backgroundColor  = DS.Colors.card
        layer.cornerRadius  = DS.cardRadius
        layer.borderWidth   = 1
        layer.borderColor   = DS.Colors.line.cgColor
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOpacity = 0.55
        layer.shadowRadius  = 30
        layer.shadowOffset  = CGSize(width: 0, height: 24)
    }

    private func addPan() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        pan.delegate = self
        pan.cancelsTouchesInView = false   // don't eat taps on subviews
        addGestureRecognizer(pan)
    }

    @objc private func handlePan(_ g: UIPanGestureRecognizer) {
        let tx = g.translation(in: self).x

        switch g.state {
        case .began:
            isDragging = true
            layer.removeAnimation(forKey: "snap")

        case .changed:
            dragX = tx
            let rot = tx * 0.04
            transform = CGAffineTransform(rotationAngle: rot * .pi / 180)
                .translatedBy(x: tx, y: 0)

        case .ended, .cancelled, .failed:
            isDragging = false
            let vel = g.velocity(in: self).x
            let threshold: CGFloat = 100
            if abs(tx) > threshold || abs(vel) > 600 {
                let dir: CGFloat = (tx > 0 || vel > 0) ? 1 : -1
                flyOut(direction: dir)
            } else {
                snapBack()
            }

        default: break
        }
    }

    private func flyOut(direction: CGFloat) {
        UIView.animate(withDuration: 0.34,
                       delay: 0,
                       options: .curveEaseIn) {
            let dx = direction * (UIScreen.main.bounds.width + 80)
            self.transform = CGAffineTransform(rotationAngle: direction * 14 * .pi / 180)
                .translatedBy(x: dx, y: 0)
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
            self.onAdvance?()
        }
    }

    private func snapBack() {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.5) {
            self.transform = .identity
        }
    }

    /// Programmatic exit (called by presenter after option selection)
    func exitProgrammatically(direction: CGFloat = 1, completion: @escaping () -> Void) {
        flyOutAndCall(direction: direction, completion: completion)
    }

    private func flyOutAndCall(direction: CGFloat, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.34,
                       delay: 0,
                       options: .curveEaseIn) {
            let dx = direction * (UIScreen.main.bounds.width + 80)
            self.transform = CGAffineTransform(rotationAngle: direction * 14 * .pi / 180)
                .translatedBy(x: dx, y: 0)
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
            completion()
        }
    }
}

extension QuestionCardView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ g: UIGestureRecognizer) -> Bool {
        guard let pan = g as? UIPanGestureRecognizer else { return true }
        let v = pan.velocity(in: self)
        return abs(v.x) > abs(v.y)
    }

}

// MARK: - Option tile (kids / alcohol / appetite)

final class OptionTileView: UIControl {
    private let emojiLabel = UILabel()
    private let nameLabel  = UILabel()
    private let noteLabel  = UILabel()
    private let check      = UIView()

    private(set) var isTileSelected = false {
        didSet { refreshStyle() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
        addTarget(self, action: #selector(dn), for: .touchDown)
        addTarget(self, action: #selector(up), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(emoji: String, name: String, note: String) {
        emojiLabel.text = emoji
        nameLabel.text  = name
        noteLabel.text  = note
    }

    func select(_ v: Bool) { isTileSelected = v }

    private func build() {
        layer.cornerRadius  = 22
        layer.borderWidth   = 1.5
        layer.borderColor   = DS.Colors.line.cgColor
        backgroundColor     = DS.Colors.card

        emojiLabel.font  = .systemFont(ofSize: 34)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font          = .systemFont(ofSize: 19, weight: .bold)
        nameLabel.textColor     = DS.Colors.txt
        nameLabel.numberOfLines = 1
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        noteLabel.font          = .systemFont(ofSize: 14, weight: .medium)
        noteLabel.textColor     = DS.Colors.txt2
        noteLabel.numberOfLines = 2
        noteLabel.translatesAutoresizingMaskIntoConstraints = false

        check.layer.cornerRadius = 12
        check.layer.borderWidth  = 2
        check.layer.borderColor  = DS.Colors.lineStrong.cgColor
        check.backgroundColor    = .clear
        check.translatesAutoresizingMaskIntoConstraints = false

        addSubview(emojiLabel)
        addSubview(nameLabel)
        addSubview(noteLabel)
        addSubview(check)

        NSLayoutConstraint.activate([
            // emoji: left-pinned, fixed width, vertically centered
            emojiLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            emojiLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            emojiLabel.widthAnchor.constraint(equalToConstant: 44),

            // check: right-pinned, fixed size, vertically centered
            check.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            check.centerYAnchor.constraint(equalTo: centerYAnchor),
            check.widthAnchor.constraint(equalToConstant: 24),
            check.heightAnchor.constraint(equalToConstant: 24),

            // name: left edge glued to emoji right, right edge to check left
            nameLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 14),
            nameLabel.trailingAnchor.constraint(equalTo: check.leadingAnchor, constant: -12),
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 18),

            // note: same horizontal anchors, below name
            noteLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            noteLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            noteLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 3),
            noteLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18),
        ])
    }

    private func refreshStyle() {
        UIView.animate(withDuration: 0.2) {
            self.layer.borderColor = self.isTileSelected
                ? DS.Colors.ember.cgColor
                : DS.Colors.line.cgColor
            self.backgroundColor = self.isTileSelected
                ? DS.Colors.chipActive
                : DS.Colors.card
            self.check.backgroundColor = self.isTileSelected ? DS.Colors.ember : .clear
            self.check.layer.borderColor = self.isTileSelected
                ? UIColor.clear.cgColor
                : DS.Colors.lineStrong.cgColor
        }
    }

    @objc private func dn() { UIView.animate(withDuration: 0.1) { self.transform = .init(scaleX: 0.98, y: 0.98) } }
    @objc private func up() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1) {
            self.transform = .identity
        }
    }
}

// MARK: - Count content (stepper + mini grill)

final class CountContentView: UIView {
    var onValueChanged: ((Int) -> Void)?
    private(set) var value: Int = 6

    private let numLabel   = UILabel()
    private let unitLabel  = UILabel()
    private let minusBtn   = StepButton(symbol: "−")
    private let plusBtn    = StepButton(symbol: "+")
    private let grillView  = GrillView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
        update()
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(value: Int) { self.value = value; update() }

    private func build() {
        numLabel.font          = DS.Fonts.stepNum
        numLabel.textColor     = DS.Colors.txt
        numLabel.textAlignment = .center

        unitLabel.font         = .systemFont(ofSize: 15, weight: .semibold)
        unitLabel.textColor    = DS.Colors.txt2
        unitLabel.textAlignment = .center

        let stepper = UIStackView(arrangedSubviews: [minusBtn, numLabel, plusBtn])
        stepper.axis      = .horizontal
        stepper.spacing   = 26
        stepper.alignment = .center

        grillView.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [stepper, unitLabel, grillView])
        stack.axis    = .vertical
        stack.spacing = 6
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            numLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
            grillView.heightAnchor.constraint(equalToConstant: 104),
            grillView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.92),
        ])

        minusBtn.addTarget(self, action: #selector(minus), for: .touchUpInside)
        plusBtn.addTarget(self,  action: #selector(plus),  for: .touchUpInside)
    }

    private func update() {
        numLabel.text = "\(value)"
        let unit: String
        switch value {
        case 1:        unit = "человек"
        case 2, 3, 4:  unit = "человека"
        default:       unit = "человек"
        }
        unitLabel.text = unit

        let skewers = min(5, max(1, Int(ceil(Double(value) / 3))))
        grillView.configure(GrillView.Config(
            skewers: skewers, meatSize: .normal, lit: true, smoke: 0.4
        ))
    }

    @objc private func minus() {
        value = max(1, value - 1)
        bounce(numLabel)
        update()
        onValueChanged?(value)
    }
    @objc private func plus() {
        value = min(30, value + 1)
        bounce(numLabel)
        update()
        onValueChanged?(value)
    }

    private func bounce(_ v: UIView) {
        UIView.animate(withDuration: 0.12) { v.transform = .init(scaleX: 1.15, y: 1.15) }
        UIView.animate(withDuration: 0.3, delay: 0.08, usingSpringWithDamping: 0.5, initialSpringVelocity: 1) {
            v.transform = .identity
        }
    }
}

final class StepButton: UIControl {
    private let label = UILabel()
    init(symbol: String) {
        super.init(frame: .zero)
        label.text          = symbol
        label.font          = .systemFont(ofSize: 32, weight: .semibold)
        label.textColor     = DS.Colors.txt
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            widthAnchor.constraint(equalToConstant: 64),
            heightAnchor.constraint(equalToConstant: 64),
        ])
        layer.cornerRadius = 32
        layer.borderWidth  = 1.5
        layer.borderColor  = DS.Colors.lineStrong.cgColor
        backgroundColor    = DS.Colors.chip
        addTarget(self, action: #selector(dn), for: .touchDown)
        addTarget(self, action: #selector(up), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    required init?(coder: NSCoder) { fatalError() }
    @objc private func dn() {
        UIView.animate(withDuration: 0.1) { self.transform = .init(scaleX: 0.90, y: 0.90) }
        backgroundColor = DS.Colors.chipActive
    }
    @objc private func up() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1) {
            self.transform = .identity
        }
        backgroundColor = DS.Colors.chip
    }
}

// MARK: - Meat tile (vertical layout, no checkbox)

final class MeatTileView: UIControl {
    private let emojiLabel = UILabel()
    private let nameLabel  = UILabel()
    private let noteLabel  = UILabel()
    private(set) var isTileSelected = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
        addTarget(self, action: #selector(dn), for: .touchDown)
        addTarget(self, action: #selector(up), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(emoji: String, name: String, note: String) {
        emojiLabel.text = emoji
        nameLabel.text  = name
        noteLabel.text  = note
    }

    func select(_ v: Bool) {
        isTileSelected = v
        UIView.animate(withDuration: 0.2) {
            self.layer.borderColor = v ? DS.Colors.ember.cgColor : DS.Colors.line.cgColor
            self.backgroundColor   = v ? DS.Colors.chipActive    : DS.Colors.card
        }
    }

    private func build() {
        layer.cornerRadius = 22
        layer.borderWidth  = 1.5
        layer.borderColor  = DS.Colors.line.cgColor
        backgroundColor    = DS.Colors.card
        setContentHuggingPriority(.required, for: .vertical)

        emojiLabel.font          = .systemFont(ofSize: 36)
        emojiLabel.textAlignment = .center

        nameLabel.font           = .systemFont(ofSize: 17, weight: .bold)
        nameLabel.textColor      = DS.Colors.txt
        nameLabel.numberOfLines  = 2
        nameLabel.textAlignment  = .center

        noteLabel.font           = .systemFont(ofSize: 13, weight: .medium)
        noteLabel.textColor      = DS.Colors.txt2
        noteLabel.numberOfLines  = 2
        noteLabel.textAlignment  = .center

        let stack = UIStackView(arrangedSubviews: [emojiLabel, nameLabel, noteLabel])
        stack.axis      = .vertical
        stack.spacing   = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
        ])
    }

    @objc private func dn() { UIView.animate(withDuration: 0.1) { self.transform = .init(scaleX: 0.97, y: 0.97) } }
    @objc private func up() { UIView.animate(withDuration: 0.18, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5) { self.transform = .identity } }
}

// MARK: - Meat grid (multi-select)

final class MeatGridView: UIView {
    /// Called whenever selection changes; passes current selected set
    var onSelectionChanged: (([MeatType]) -> Void)?

    private var selection: Set<MeatType>        = [.pork]
    private var tiles: [MeatType: MeatTileView] = [:]
    private var wideTile: MeatTileWideView?
    private var wideMeat: MeatType?

    func configure(selected: [MeatType]) {
        self.selection = Set(selected)
        build()
    }

    private func build() {
        subviews.forEach { $0.removeFromSuperview() }
        tiles = [:]
        let meats = Array(MeatType.allCases)

        var views: [MeatTileView] = []
        for (i, m) in meats.enumerated() {
            let t = MeatTileView()
            t.configure(emoji: m.emoji, name: m.name, note: m.note)
            t.tag = i
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            tap.cancelsTouchesInView = false
            t.addGestureRecognizer(tap)
            tiles[m] = t
            views.append(t)
        }
        // Reflect initial selection
        tiles.forEach { m, t in t.select(selection.contains(m)) }

        let colStack = UIStackView()
        colStack.axis         = .vertical
        colStack.spacing      = 12
        colStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(colStack)
        NSLayoutConstraint.activate([
            colStack.topAnchor.constraint(equalTo: topAnchor),
            colStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            colStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            colStack.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

        var idx = 0
        while idx < views.count {
            if idx == views.count - 1 && views.count % 2 == 1 {
                // Wide last tile (row layout)
                let wide = MeatTileWideView()
                let m    = meats[idx]
                wide.configure(emoji: m.emoji, name: m.name, note: m.note)
                wide.tag = idx
                let wideMeatCapture = m
                wide.addAction(UIAction { [weak self, weak wide] _ in
                    guard let self, let wide else { return }
                    self.toggle(wideMeatCapture, tile: wide)
                }, for: .touchUpInside)
                if selection.contains(m) { wide.select(true) }
                wideTile = wide
                wideMeat = m
                colStack.addArrangedSubview(wide)
                wide.heightAnchor.constraint(equalToConstant: 72).isActive = true
            } else {
                let row = UIStackView(arrangedSubviews: [views[idx], views[idx + 1]])
                row.axis         = .horizontal
                row.spacing      = 12
                row.distribution = .fillEqually
                colStack.addArrangedSubview(row)
                row.heightAnchor.constraint(equalToConstant: 110).isActive = true
                idx += 1
            }
            idx += 1
        }
    }

    private func toggle(_ m: MeatType, tile: UIControl) {
        if selection.contains(m) {
            guard selection.count > 1 else { return }   // keep at least one
            selection.remove(m)
            (tile as? MeatTileView)?.select(false)
            (tile as? MeatTileWideView)?.select(false)
        } else {
            selection.insert(m)
            (tile as? MeatTileView)?.select(true)
            (tile as? MeatTileWideView)?.select(true)
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onSelectionChanged?(Array(selection))
    }

    @objc private func handleTap(_ g: UITapGestureRecognizer) {
        let meats = Array(MeatType.allCases)
        guard let tile = g.view as? MeatTileView,
              tile.tag < meats.count else { return }
        toggle(meats[tile.tag], tile: tile)
    }
}

// MARK: - Wide meat tile (last odd item, horizontal layout)

final class MeatTileWideView: UIControl {
    private let emojiLabel = UILabel()
    private let nameLabel  = UILabel()
    private let noteLabel  = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
        addTarget(self, action: #selector(dn), for: .touchDown)
        addTarget(self, action: #selector(up), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(emoji: String, name: String, note: String) {
        emojiLabel.text = emoji
        nameLabel.text  = name
        noteLabel.text  = note
    }

    func select(_ v: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.layer.borderColor = v ? DS.Colors.ember.cgColor : DS.Colors.line.cgColor
            self.backgroundColor   = v ? DS.Colors.chipActive    : DS.Colors.card
        }
    }

    private func build() {
        layer.cornerRadius = 22
        layer.borderWidth  = 1.5
        layer.borderColor  = DS.Colors.line.cgColor
        backgroundColor    = DS.Colors.card

        emojiLabel.font  = .systemFont(ofSize: 32)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font          = .systemFont(ofSize: 17, weight: .bold)
        nameLabel.textColor     = DS.Colors.txt
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        noteLabel.font          = .systemFont(ofSize: 13, weight: .medium)
        noteLabel.textColor     = DS.Colors.txt2
        noteLabel.numberOfLines = 2
        noteLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(emojiLabel)
        addSubview(nameLabel)
        addSubview(noteLabel)

        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            emojiLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            emojiLabel.widthAnchor.constraint(equalToConstant: 44),

            nameLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 14),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),

            noteLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            noteLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            noteLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 3),
            noteLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
        ])
    }

    @objc private func dn() { UIView.animate(withDuration: 0.1) { self.transform = .init(scaleX: 0.97, y: 0.97) } }
    @objc private func up() { UIView.animate(withDuration: 0.18, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5) { self.transform = .identity } }
}
