import UIKit

final class SignatureViewController: UIViewController, SignatureViewProtocol {

    private let presenter: SignaturePresenter

    // MARK: - UI
    private let kickerLabel  = KickerLabel("Финальный штрих")
    private let titleLabel   = UILabel()
    private let subLabel     = UILabel()
    private let countLabel   = UILabel()
    private let totalLabel   = UILabel()
    private let unitLabel    = UILabel()
    private let skewerView   = SignatureSkewerView()
    private let grillView    = GrillView()
    private let doneBtn      = EmberButton()

    init(presenter: SignaturePresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.Colors.bg1
        buildLayout()
        skewerView.presenter = presenter
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        grillView.startAnimating()
        updateUI(progress: 0, loaded: 0, total: presenter.totalPieces)
    }

    // MARK: - SignatureViewProtocol

    func updateProgress(_ p: CGFloat, loaded: Int, total: Int) {
        skewerView.update(progress: p, loaded: loaded, total: total)
        updateUI(progress: p, loaded: loaded, total: total)
    }

    func showCompletion() {
        grillView.configure(GrillView.Config(
            skewers: 0, meatSize: .normal, lit: true, fire: true, smoke: 0.95))
        grillView.startAnimating()
        skewerView.showDoneState()

        titleLabel.text = "Шашлык на мангале! 🔥"
        subLabel.text   = "Угли раскалились, дым пошёл"

        UIView.animate(withDuration: 0.5, delay: 0.2,
                       usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.doneBtn.alpha     = 1
            self.doneBtn.transform = .identity
        }
        flashHaptic()
    }

    func triggerHaptic(_ style: HapticStyle) { fireHaptic(style) }

    // MARK: - Build

    private func buildLayout() {
        // Title block
        titleLabel.text          = "Нанижи шашлык"
        titleLabel.font          = DS.Fonts.h1
        titleLabel.textColor     = DS.Colors.txt
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center

        subLabel.text          = "Тяни шампур вправо — мясо садится на него кусок за куском"
        subLabel.font          = DS.Fonts.body
        subLabel.textColor     = DS.Colors.txt2
        subLabel.numberOfLines = 0
        subLabel.textAlignment = .center

        let headerStack = UIStackView(arrangedSubviews: [kickerLabel, titleLabel, subLabel])
        headerStack.axis      = .vertical
        headerStack.spacing   = 8
        headerStack.alignment = .center
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        // Progress counter
        countLabel.font          = DS.Fonts.bigNum
        countLabel.textColor     = DS.Colors.txt
        countLabel.textAlignment = .center
        countLabel.text          = "0"

        totalLabel.font          = .systemFont(ofSize: 24, weight: .bold)
        totalLabel.textColor     = DS.Colors.txt3
        totalLabel.text          = " / \(presenter.totalPieces)"

        unitLabel.font           = DS.Fonts.caption
        unitLabel.textColor      = DS.Colors.txt3
        unitLabel.text           = "кусков на шампуре"
        unitLabel.textAlignment  = .center

        let numRow = UIStackView(arrangedSubviews: [countLabel, totalLabel])
        numRow.axis      = .horizontal
        numRow.alignment = .lastBaseline
        numRow.spacing   = 0

        let counterStack = UIStackView(arrangedSubviews: [numRow, unitLabel])
        counterStack.axis      = .vertical
        counterStack.spacing   = 2
        counterStack.alignment = .center
        counterStack.translatesAutoresizingMaskIntoConstraints = false

        // Skewer
        skewerView.translatesAutoresizingMaskIntoConstraints = false

        // Grill at bottom
        grillView.configure(GrillView.Config(
            skewers: 0, meatSize: .normal, lit: true, fire: false, smoke: 0.25))
        grillView.translatesAutoresizingMaskIntoConstraints = false

        // Done button (hidden until complete)
        doneBtn.setTitle("Показать расчёт  🍢", for: .normal)
        doneBtn.alpha     = 0
        doneBtn.transform = CGAffineTransform(translationX: 0, y: 30)
        doneBtn.translatesAutoresizingMaskIntoConstraints = false
        doneBtn.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)

        view.addSubview(headerStack)
        view.addSubview(counterStack)
        view.addSubview(skewerView)
        view.addSubview(grillView)
        view.addSubview(doneBtn)

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DS.pad),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DS.pad),

            counterStack.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 20),
            counterStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            skewerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            skewerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            skewerView.heightAnchor.constraint(equalToConstant: 90),
            skewerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20),

            grillView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            grillView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            grillView.heightAnchor.constraint(equalToConstant: 190),
            grillView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 10),

            doneBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DS.pad),
            doneBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DS.pad),
            doneBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -28),
            doneBtn.heightAnchor.constraint(equalToConstant: DS.btnHeight),
        ])
    }

    // MARK: - Helpers

    private func updateUI(progress: CGFloat, loaded: Int, total: Int) {
        countLabel.text  = "\(loaded)"
        totalLabel.text  = " / \(total)"
        let isDone = loaded >= total
        countLabel.textColor = isDone ? DS.Colors.ember : DS.Colors.txt
    }

    private func flashHaptic() {
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = DS.Colors.ember.withAlphaComponent(0.12)
        overlay.isUserInteractionEnabled = false
        view.addSubview(overlay)
        UIView.animate(withDuration: 0.35, animations: { overlay.alpha = 0 }) { _ in
            overlay.removeFromSuperview()
        }
    }

    @objc private func didTapDone() {
        fireHaptic(.medium)
        presenter.didTapShowResults()
    }
}
