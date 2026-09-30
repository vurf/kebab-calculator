import UIKit

final class HeroViewController: UIViewController, HeroViewProtocol {
    private let presenter: HeroPresenter
    private let grillView   = GrillView()
    private let kickerLabel = KickerLabel("Шашлыкатор")
    private let titleLabel  = UILabel()
    private let subLabel    = UILabel()
    private let startBtn    = EmberButton()
    private let hintLabel   = UILabel()

    init(presenter: HeroPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        buildBackground()
        buildGrill()
        buildText()
        buildCTA()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        grillView.startAnimating()
        animateIn()
    }

    // MARK: - Build

    private func buildBackground() {
        view.backgroundColor = DS.Colors.bg1
        let grad         = CAGradientLayer()
        grad.type        = .radial
        grad.colors      = [DS.Colors.bgGradA.cgColor, DS.Colors.bgGradB.cgColor]
        grad.startPoint  = CGPoint(x: 0.5, y: 0)
        grad.endPoint    = CGPoint(x: 0.5, y: 1)
        grad.frame       = view.bounds
        view.layer.insertSublayer(grad, at: 0)
    }

    private func buildGrill() {
        grillView.configure(GrillView.Config(
            skewers: 3, meatSize: .normal, lit: true, fire: true, smoke: 0.9))
        grillView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(grillView)
        NSLayoutConstraint.activate([
            grillView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            grillView.topAnchor.constraint(equalTo: view.topAnchor,
                                           constant: view.bounds.height * 0.16),
            grillView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.88),
            grillView.heightAnchor.constraint(equalToConstant: 210),
        ])
        // Float animation
        let float         = CAKeyframeAnimation(keyPath: "transform.translation.y")
        float.values      = [0, -8, 0]
        float.keyTimes    = [0, 0.5, 1.0]
        float.duration    = 6.0
        float.repeatCount = .infinity
        float.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        grillView.layer.add(float, forKey: "float")
    }

    private func buildText() {
        titleLabel.text          = "Сколько шашлыка\nнужно?"
        titleLabel.font          = DS.Fonts.hero
        titleLabel.textColor     = DS.Colors.txt
        titleLabel.numberOfLines = 0

        subLabel.text            = "Рассчитаем всё за 30 секунд — мясо, уголь, овощи и напитки на вашу компанию."
        subLabel.font            = .systemFont(ofSize: 19, weight: .medium)
        subLabel.textColor       = DS.Colors.txt2
        subLabel.numberOfLines   = 0

        hintLabel.text           = "Свайпай карточки — мангал соберётся сам"
        hintLabel.font           = DS.Fonts.caption
        hintLabel.textColor      = DS.Colors.txt3
        hintLabel.textAlignment  = .center
        hintLabel.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [kickerLabel, titleLabel, subLabel])
        stack.axis    = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        view.addSubview(hintLabel)

        startBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(startBtn)
        startBtn.setTitle("Начать  🔥", for: .normal)
        startBtn.addTarget(self, action: #selector(didTapStart), for: .touchUpInside)

        NSLayoutConstraint.activate([
            startBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DS.pad),
            startBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DS.pad),
            startBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -44),
            startBtn.heightAnchor.constraint(equalToConstant: DS.btnHeight),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DS.pad),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DS.pad),
            stack.bottomAnchor.constraint(equalTo: startBtn.topAnchor, constant: -28),
            hintLabel.topAnchor.constraint(equalTo: startBtn.bottomAnchor, constant: 14),
            hintLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DS.pad),
            hintLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DS.pad),
        ])
    }

    private func buildCTA() {}   // already done in buildText

    // MARK: - Animation

    private func animateIn() {
        let views: [UIView] = [kickerLabel, titleLabel, subLabel, startBtn, hintLabel]
        views.forEach {
            $0.alpha     = 0
            $0.transform = CGAffineTransform(translationX: 0, y: 26)
        }
        views.enumerated().forEach { i, v in
            UIView.animate(withDuration: 0.6, delay: 0.10 + Double(i) * 0.08,
                           usingSpringWithDamping: 0.75, initialSpringVelocity: 0.5) {
                v.alpha     = 1
                v.transform = .identity
            }
        }
    }

    // MARK: - Actions

    @objc private func didTapStart() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        flashHaptic()
        presenter.didTapStart()
    }

    private func flashHaptic() {
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = DS.Colors.ember.withAlphaComponent(0.10)
        view.addSubview(overlay)
        UIView.animate(withDuration: 0.32, animations: { overlay.alpha = 0 }) { _ in
            overlay.removeFromSuperview()
        }
    }
}
