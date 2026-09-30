import UIKit

final class ResultsViewController: UIViewController, ResultsViewProtocol {

    private let presenter: ResultsPresenter
    private let scrollView = UIScrollView()
    private let content    = UIView()
    private var displayLinks: [CADisplayLink] = []

    init(presenter: ResultsPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.Colors.bg1
        buildScrollLayout()
        buildBackButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        displayLinks.forEach { $0.invalidate() }
    }

    // MARK: - Build

    private func buildBackButton() {
        let btn = UIButton(type: .system)
        btn.setTitle("↺  Пересчитать", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.tintColor = DS.Colors.txt3
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(restart), for: .touchUpInside)
        view.addSubview(btn)
        NSLayoutConstraint.activate([
            btn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            btn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DS.pad),
        ])
    }

    private func buildScrollLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        content.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: scrollView.topAnchor),
            content.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            content.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        buildResultsContent()
    }

    private func buildResultsContent() {
        let r = presenter.result
        let eStr = r.eaters == r.eaters.rounded() ? String(Int(r.eaters)) : String(r.eaters)

        // Header
        let kicker = KickerLabel("Мангал готов 🔥")
        let title  = UILabel(); title.text = "Ваш расчёт на \(eStr) едоков"
        title.font = DS.Fonts.h1; title.textColor = DS.Colors.txt; title.numberOfLines = 0
        let sub    = UILabel(); sub.text = "Список готов — осталось закупиться"
        sub.font   = DS.Fonts.body; sub.textColor = DS.Colors.txt2

        let headerStack = UIStackView(arrangedSubviews: [kicker, title, sub])
        headerStack.axis    = .vertical
        headerStack.spacing = 8
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        // Hero grill
        let grillView = GrillView()
        grillView.configure(GrillView.Config(
            skewers: min(r.skewers, 5), meatSize: presenter.inputs.appetite,
            lit: true, fire: true, smoke: 0.7, cooked: true))
        grillView.translatesAutoresizingMaskIntoConstraints = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { grillView.startAnimating() }

        // Top 3 stat cards
        let list      = presenter.list
        let top3Stack = UIStackView()
        top3Stack.axis         = .horizontal
        top3Stack.spacing      = 10
        top3Stack.distribution = .fillEqually
        for item in list.prefix(3) {
            top3Stack.addArrangedSubview(makeStatCard(item: item))
        }
        top3Stack.translatesAutoresizingMaskIntoConstraints = false

        // Shopping list card
        let shoppingCard = buildShoppingCard()

        // Action buttons
        let shareBtn  = GhostButton(title: "📤  Поделиться")
        let saveBtn   = GhostButton(title: "🔖  Сохранить")
        let actRow    = UIStackView(arrangedSubviews: [shareBtn, saveBtn])
        actRow.axis         = .horizontal
        actRow.spacing      = 12
        actRow.distribution = .fillEqually

        let restartBtn = EmberButton()
        restartBtn.setTitle("Пересчитать заново", for: .normal)
        restartBtn.addTarget(self, action: #selector(restart), for: .touchUpInside)
        restartBtn.heightAnchor.constraint(equalToConstant: DS.btnHeight).isActive = true

        shareBtn.heightAnchor.constraint(equalToConstant: 56).isActive = true
        saveBtn.heightAnchor.constraint(equalToConstant: 56).isActive = true

        let main = UIStackView(arrangedSubviews: [
            headerStack, grillView, top3Stack, shoppingCard, actRow, restartBtn
        ])
        main.axis    = .vertical
        main.spacing = 18
        main.translatesAutoresizingMaskIntoConstraints = false

        content.addSubview(main)
        NSLayoutConstraint.activate([
            main.topAnchor.constraint(equalTo: content.topAnchor, constant: 72),
            main.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: DS.pad),
            main.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -DS.pad),
            main.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -40),
            grillView.heightAnchor.constraint(equalToConstant: 170),
        ])

        shareBtn.addAction(UIAction { [weak self] _ in self?.shareResults() }, for: .touchUpInside)
    }

    private func makeStatCard(item: ShoppingItem) -> UIView {
        let card     = UIView()
        card.backgroundColor  = DS.Colors.card
        card.layer.cornerRadius = 22
        card.layer.borderWidth  = 1
        card.layer.borderColor  = DS.Colors.line.cgColor

        let emojiLbl = UILabel(); emojiLbl.text = item.icon; emojiLbl.font = .systemFont(ofSize: 24)
        let valLbl   = UILabel()
        valLbl.font  = DS.Fonts.statVal; valLbl.textColor = DS.Colors.txt
        valLbl.attributedText = animatableAttr(target: item.value, unit: item.unit)
        let nameLbl  = UILabel(); nameLbl.text = item.label
        nameLbl.font = .systemFont(ofSize: 13, weight: .semibold)
        nameLbl.textColor = DS.Colors.txt2

        let stack    = UIStackView(arrangedSubviews: [emojiLbl, valLbl, nameLbl])
        stack.axis   = .vertical; stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
        ])

        // Counter animation
        startCounter(label: valLbl, target: item.value, unit: item.unit, delay: 0.3)
        return card
    }

    private func animatableAttr(target: Double, unit: String) -> NSAttributedString {
        let s = NSMutableAttributedString(
            string: unit == "шт" ? "\(Int(target))" : String(format: "%.1f", target),
            attributes: [.font: DS.Fonts.statVal, .foregroundColor: DS.Colors.txt])
        s.append(NSAttributedString(
            string: " \(unit)",
            attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .semibold),
                         .foregroundColor: DS.Colors.txt3]))
        return s
    }

    private func startCounter(label: UILabel, target: Double, unit: String, delay: Double) {
        let start    = CACurrentMediaTime() + delay
        let duration = 1.1
        var link: CADisplayLink?
        link = CADisplayLink(target: self, selector: #selector(tick))
        link?.add(to: .main, forMode: .default)
        displayLinks.append(link!)
        // Store state in objc associated object
        objc_setAssociatedObject(link!, &AssocKeys.target,   target,   .OBJC_ASSOCIATION_RETAIN)
        objc_setAssociatedObject(link!, &AssocKeys.start,    start,    .OBJC_ASSOCIATION_RETAIN)
        objc_setAssociatedObject(link!, &AssocKeys.duration, duration, .OBJC_ASSOCIATION_RETAIN)
        objc_setAssociatedObject(link!, &AssocKeys.label,    label,    .OBJC_ASSOCIATION_RETAIN)
        objc_setAssociatedObject(link!, &AssocKeys.unit,     unit,     .OBJC_ASSOCIATION_RETAIN)
    }

    @objc private func tick(_ link: CADisplayLink) {
        guard let target   = objc_getAssociatedObject(link, &AssocKeys.target)   as? Double,
              let start    = objc_getAssociatedObject(link, &AssocKeys.start)    as? Double,
              let dur      = objc_getAssociatedObject(link, &AssocKeys.duration) as? Double,
              let label    = objc_getAssociatedObject(link, &AssocKeys.label)    as? UILabel,
              let unit     = objc_getAssociatedObject(link, &AssocKeys.unit)     as? String
        else { return }

        let now = CACurrentMediaTime()
        if now < start { return }
        let t = min(1, (now - start) / dur)
        let e = 1 - pow(1 - t, 3)   // easeOutCubic
        let v = target * e

        let txt = unit == "шт" ? "\(Int(v.rounded()))" : String(format: "%.1f", v)
        let s   = NSMutableAttributedString(
            string: txt,
            attributes: [.font: DS.Fonts.statVal, .foregroundColor: DS.Colors.txt])
        s.append(NSAttributedString(
            string: " \(unit)",
            attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .semibold),
                         .foregroundColor: DS.Colors.txt3]))
        label.attributedText = s

        if t >= 1 { link.invalidate() }
    }

    private func buildShoppingCard() -> UIView {
        let card = UIView()
        card.backgroundColor   = DS.Colors.card
        card.layer.cornerRadius = 22
        card.layer.borderWidth  = 1
        card.layer.borderColor  = DS.Colors.line.cgColor

        let header = UILabel()
        header.text          = "СПИСОК ПОКУПОК"
        header.font          = .systemFont(ofSize: 12, weight: .bold)
        header.textColor     = DS.Colors.txt3
        header.letterSpacing = 0.1

        let stack = UIStackView(arrangedSubviews: [header])
        stack.axis    = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false

        for (i, item) in presenter.list.enumerated() {
            let row = makeShoppingRow(item: item, last: i == presenter.list.count - 1, delay: 0.5 + Double(i) * 0.07)
            stack.addArrangedSubview(row)
        }

        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
        ])
        return card
    }

    private func makeShoppingRow(item: ShoppingItem, last: Bool, delay: Double) -> UIView {
        let row = UIView()
        let ic  = UILabel(); ic.text = item.icon; ic.font = .systemFont(ofSize: 24)
        let bg  = UIView(); bg.backgroundColor = DS.Colors.chip; bg.layer.cornerRadius = 14
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.addSubview(ic)
        ic.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bg.widthAnchor.constraint(equalToConstant: 46),
            bg.heightAnchor.constraint(equalToConstant: 46),
            ic.centerXAnchor.constraint(equalTo: bg.centerXAnchor),
            ic.centerYAnchor.constraint(equalTo: bg.centerYAnchor),
        ])

        let name = UILabel(); name.text = item.label
        name.font = .systemFont(ofSize: 16, weight: .semibold); name.textColor = DS.Colors.txt2

        let val  = UILabel()
        val.font = DS.Fonts.statVal; val.textColor = DS.Colors.txt
        startCounter(label: val, target: item.value, unit: item.unit, delay: delay)

        let h = UIStackView(arrangedSubviews: [bg, name, UIView(), val])
        h.axis = .horizontal; h.spacing = 16; h.alignment = .center
        h.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(h)

        NSLayoutConstraint.activate([
            h.topAnchor.constraint(equalTo: row.topAnchor, constant: 8),
            h.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -8),
            h.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            h.trailingAnchor.constraint(equalTo: row.trailingAnchor),
        ])

        if !last {
            let sep = UIView(); sep.backgroundColor = DS.Colors.line
            sep.translatesAutoresizingMaskIntoConstraints = false
            row.addSubview(sep)
            NSLayoutConstraint.activate([
                sep.heightAnchor.constraint(equalToConstant: 0.5),
                sep.bottomAnchor.constraint(equalTo: row.bottomAnchor),
                sep.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 62),
                sep.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            ])
        }
        return row
    }

    // MARK: - Animation

    private func animateIn() {
        content.subviews.first?.subviews.enumerated().forEach { i, v in
            v.alpha     = 0
            v.transform = CGAffineTransform(translationX: 0, y: 24)
            UIView.animate(withDuration: 0.6, delay: 0.05 + Double(i) * 0.07,
                           usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
                v.alpha     = 1
                v.transform = .identity
            }
        }
    }

    // MARK: - Actions

    @objc private func restart() {
        fireHaptic(.medium)
        displayLinks.forEach { $0.invalidate() }
        presenter.didTapRestart()
    }

    private func shareResults() {
        fireHaptic(.light)
        let r = presenter.result
        let txt = """
        🔥 Шашлыкатор — расчёт BBQ

        🍖 Мясо: \(r.meat) кг
        🧅 Лук: \(r.onion) кг
        🔥 Уголь: \(r.charcoal) кг
        🥗 Овощи: \(r.veg) кг
        🥤 Напитки: \(r.drinks) л

        Рассчитано за 30 секунд через Шашлыкатор 🍢
        """
        let vc = UIActivityViewController(activityItems: [txt], applicationActivities: nil)
        present(vc, animated: true)
    }
}

// MARK: - Associated keys for display link

private enum AssocKeys {
    static var target   = "target"
    static var start    = "start"
    static var duration = "duration"
    static var label    = "label"
    static var unit     = "unit"
}

// MARK: - UILabel letterSpacing helper

extension UILabel {
    var letterSpacing: CGFloat {
        get { 0 }
        set {
            guard let t = text else { return }
            let s = NSMutableAttributedString(string: t)
            s.addAttribute(.kern, value: newValue * font.pointSize,
                           range: NSRange(location: 0, length: s.length))
            attributedText = s
        }
    }
}
