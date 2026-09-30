import UIKit

final class QuestionFlowViewController: UIViewController, QuestionFlowViewProtocol {

    private let presenter: QuestionFlowPresenter

    // MARK: - UI
    private let dotsView     = ProgressDotsView()
    private let counterLabel = UILabel()
    private let backBtn      = UIButton(type: .system)
    private var activeCard:  QuestionCardView?
    private var peekCard:    UIView?

    init(presenter: QuestionFlowPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.Colors.bg1
        buildHeader()
        buildPeek()
        showQuestion(presenter.currentStep,
                     stepIndex: 0,
                     total: presenter.totalSteps)
    }

    // MARK: - QuestionFlowViewProtocol

    func showQuestion(_ step: QuestionStep, stepIndex: Int, total: Int) {
        dotsView.update(current: stepIndex)
        counterLabel.text = "\(stepIndex + 1) / \(total)"

        let card = makeCard(for: step, stepIndex: stepIndex)
        card.alpha     = 0
        card.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)

        // Manual swipe → advance (only useful for count step; options auto-advance on selection)
        card.onAdvance = { [weak self] in self?.presenter.advance() }

        // Insert above peek card but below any overlays
        if let peek = peekCard {
            view.insertSubview(card, aboveSubview: peek)
        } else {
            view.addSubview(card)
        }
        pinCard(card)

        UIView.animate(withDuration: 0.4, delay: 0,
                       usingSpringWithDamping: 0.80, initialSpringVelocity: 0) {
            card.alpha     = 1
            card.transform = .identity
        }
        activeCard = card
    }

    func exitCard(direction: CGFloat, completion: @escaping () -> Void) {
        activeCard?.exitProgrammatically(direction: direction, completion: completion)
    }

    func triggerHaptic(_ style: HapticStyle) { fireHaptic(style) }

    // MARK: - Build helpers

    private func buildHeader() {
        dotsView.configure(total: presenter.totalSteps)
        dotsView.translatesAutoresizingMaskIntoConstraints = false

        counterLabel.font      = DS.Fonts.caption
        counterLabel.textColor = DS.Colors.txt3
        counterLabel.translatesAutoresizingMaskIntoConstraints = false

        backBtn.setTitle("↺", for: .normal)
        backBtn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        backBtn.tintColor = DS.Colors.txt2
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        backBtn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        backBtn.layer.cornerRadius = 19
        backBtn.layer.borderWidth  = 1
        backBtn.layer.borderColor  = DS.Colors.line.cgColor
        backBtn.backgroundColor    = DS.Colors.chip

        view.addSubview(dotsView)
        view.addSubview(counterLabel)
        view.addSubview(backBtn)

        NSLayoutConstraint.activate([
            dotsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DS.pad),
            dotsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            dotsView.heightAnchor.constraint(equalToConstant: 16),
            counterLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DS.pad),
            counterLabel.centerYAnchor.constraint(equalTo: dotsView.centerYAnchor),
            backBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DS.pad),
            backBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
            backBtn.widthAnchor.constraint(equalToConstant: 38),
            backBtn.heightAnchor.constraint(equalToConstant: 38),
        ])

        // Dots get their size from ProgressDotsView.configure — nothing extra needed
    }

    private func buildPeek() {
        let peek = UIView()
        peek.backgroundColor  = DS.Colors.card
        peek.layer.cornerRadius = DS.cardRadius
        peek.layer.borderWidth  = 1
        peek.layer.borderColor  = DS.Colors.line.cgColor
        peek.layer.shadowColor  = UIColor.black.cgColor
        peek.layer.shadowOpacity = 0.3
        peek.layer.shadowRadius  = 20
        peek.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(peek)

        let top = view.safeAreaLayoutGuide.topAnchor
        NSLayoutConstraint.activate([
            peek.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DS.pad + 12),
            peek.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DS.pad - 12),
            peek.topAnchor.constraint(equalTo: top, constant: 58),
            peek.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
        ])
        peek.transform = CGAffineTransform(scaleX: 0.94, y: 0.94).translatedBy(x: 0, y: 14)
        peek.alpha = 0.50
        peekCard = peek
    }

    private func makeCard(for step: QuestionStep, stepIndex: Int) -> QuestionCardView {
        let card = QuestionCardView()

        // Header inside card
        let kicker = KickerLabel("Вопрос \(stepIndex + 1)")
        let title  = UILabel(); title.text = step.title
        title.font = DS.Fonts.h1; title.textColor = DS.Colors.txt; title.numberOfLines = 0
        let sub    = UILabel(); sub.text = step.subtitle
        sub.font   = DS.Fonts.body; sub.textColor = DS.Colors.txt2; sub.numberOfLines = 0

        let content = makeContent(for: step, card: card)

        let topStack = UIStackView(arrangedSubviews: [kicker, title, sub])
        topStack.axis    = .vertical
        topStack.spacing = 6

        topStack.translatesAutoresizingMaskIntoConstraints = false
        content.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(topStack)
        card.addSubview(content)

        // CTA for count and meat steps
        if step == .count || step == .meat {
            let btn = EmberButton()
            btn.setTitle("Дальше", for: .normal)
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.heightAnchor.constraint(equalToConstant: DS.btnHeight).isActive = true
            btn.setTitle(step == .meat ? "Дальше 🔥" : "Дальше", for: .normal)
            btn.addTarget(self, action: #selector(advanceFromCount), for: .touchUpInside)
            card.addSubview(btn)
            NSLayoutConstraint.activate([
                topStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
                topStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
                topStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
                content.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 20),
                content.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
                content.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
                btn.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
                btn.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
                btn.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24),
                content.bottomAnchor.constraint(lessThanOrEqualTo: btn.topAnchor, constant: -12),
            ])
        } else {
            // Header top-pinned; content centered in remaining space
            NSLayoutConstraint.activate([
                topStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
                topStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
                topStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
                content.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
                content.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
                content.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 20),
                content.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -24),
            ])
        }
        return card
    }

    private func makeContent(for step: QuestionStep, card: QuestionCardView) -> UIView {
        switch step {
        case .count:
            let v = CountContentView()
            v.configure(value: presenter.inputs.count)
            v.onValueChanged = { [weak self] n in
                self?.presenter.setCount(n)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            return v

        case .kids:
            let kids = Array(KidsOption.allCases)
            return makeOptionStack(options: kids, current: presenter.inputs.kids.rawValue, card: card) { [weak self] idx in
                self?.presenter.setKids(kids[idx])
                self?.presenter.advance()
            }

        case .alcohol:
            let alc = Array(AlcoholOption.allCases)
            return makeOptionStack(options: alc, current: presenter.inputs.alcohol.rawValue, card: card) { [weak self] idx in
                self?.presenter.setAlcohol(alc[idx])
                self?.presenter.advance()
            }

        case .appetite:
            let app = Array(AppetiteOption.allCases)
            return makeOptionStack(options: app, current: presenter.inputs.appetite.rawValue, card: card) { [weak self] idx in
                self?.presenter.setAppetite(app[idx])
                self?.presenter.advance()
            }

        case .meat:
            let v = MeatGridView()
            v.configure(selected: presenter.selectedMeats)
            v.onSelectionChanged = { [weak self] meats in
                self?.presenter.setMeats(meats)
            }
            return v
        }
    }

    private func makeOptionStack<T: RawRepresentable>(
        options: [T],
        current: T.RawValue,
        card: QuestionCardView,
        onSelect: @escaping (Int) -> Void
    ) -> UIView where T.RawValue == String {
        let stack = UIStackView()
        stack.axis    = .vertical
        stack.spacing = 12

        var tiles: [OptionTileView] = []
        for (i, opt) in options.enumerated() {
            let tile = OptionTileView()
            let emoji: String
            let name:  String
            let note:  String
            if let o = opt as? KidsOption     { emoji = o.emoji; name = o.name; note = o.note }
            else if let o = opt as? AlcoholOption  { emoji = o.emoji; name = o.name; note = o.note }
            else if let o = opt as? AppetiteOption { emoji = o.emoji; name = o.name; note = o.note }
            else { emoji = ""; name = ""; note = "" }
            tile.configure(emoji: emoji, name: name, note: note)
            tile.select(opt.rawValue == current)
            tiles.append(tile)
            let idx = i
            tile.addAction(UIAction { [weak tile] _ in
                tiles.forEach { $0.select(false) }
                tile?.select(true)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                    onSelect(idx)
                }
            }, for: .touchUpInside)
            stack.addArrangedSubview(tile)
        }
        return stack
    }

    private func pinCard(_ card: QuestionCardView) {
        card.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DS.pad),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DS.pad),
            card.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 52),
            card.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
        ])
    }

    @objc private func advanceFromCount() {
        presenter.advance()
    }

    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }
}
