import UIKit

/// Full-screen interactive signature moment:
/// user drags the skewer right, meat threads piece-by-piece.
final class SignatureSkewerView: UIView {

    // MARK: Public
    var presenter: SignaturePresenter?

    // MARK: Layers
    private let rodLayer   = CAGradientLayer()
    private let ringLayer  = CAShapeLayer()
    private let arrowLabel = UILabel()
    private var pieceLayers: [CALayer] = []

    // MARK: State
    private var dragStartX: CGFloat = 0
    private var baseProgress: CGFloat = 0
    private var isDragging = false
    private let rodWidth: CGFloat = 320
    private var pieceSlot: CGFloat { rodWidth / CGFloat((presenter?.totalPieces ?? 8) + 1) }

    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
        addPan()
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Build

    private func build() {
        backgroundColor = .clear
        buildRod()
        buildArrow()
    }

    private func buildRod() {
        let h: CGFloat = 7
        let y = bounds.midY - h/2

        rodLayer.frame       = CGRect(x: bounds.midX - rodWidth/2 - 35, y: y, width: rodWidth + 70, height: h)
        rodLayer.cornerRadius = h/2
        rodLayer.colors       = [UIColor(hex: "efe9e0").cgColor,
                                 UIColor(hex: "a39c93").cgColor,
                                 UIColor(hex: "6c665f").cgColor]
        rodLayer.locations    = [0, 0.55, 1.0]
        rodLayer.startPoint   = CGPoint(x: 0.5, y: 0)
        rodLayer.endPoint     = CGPoint(x: 0.5, y: 1)
        layer.addSublayer(rodLayer)

        // Handle ring
        let ringRect = CGRect(x: bounds.midX + rodWidth/2 + 16, y: y - 7, width: 22, height: 22)
        let path = UIBezierPath(ovalIn: ringRect)
        ringLayer.path        = path.cgPath
        ringLayer.strokeColor = UIColor(hex: "cfc8be").cgColor
        ringLayer.lineWidth   = 4
        ringLayer.fillColor   = UIColor.clear.cgColor
        layer.addSublayer(ringLayer)

        // Pulse ring animation
        let pulse = CAKeyframeAnimation(keyPath: "shadowRadius")
        pulse.values    = [0, 22, 0]
        pulse.keyTimes  = [0, 0.70, 1.0]
        pulse.duration  = 1.4
        pulse.repeatCount = .infinity
        ringLayer.shadowColor   = DS.Colors.ember.cgColor
        ringLayer.shadowOpacity = 0.6
        ringLayer.add(pulse, forKey: "pulse")
    }

    private func buildArrow() {
        arrowLabel.text      = "→"
        arrowLabel.font      = .systemFont(ofSize: 28, weight: .heavy)
        arrowLabel.textColor = DS.Colors.ember
        arrowLabel.sizeToFit()
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(arrowLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let h: CGFloat = 7
        let y = bounds.midY - h/2
        rodLayer.frame = CGRect(x: bounds.midX - rodWidth/2 - 35, y: y, width: rodWidth + 70, height: h)

        let ringX = bounds.midX + rodWidth/2 + 16
        ringLayer.path = UIBezierPath(ovalIn: CGRect(x: ringX, y: y - 7, width: 22, height: 22)).cgPath

        arrowLabel.center = CGPoint(x: ringX + 48, y: bounds.midY)
    }

    // MARK: - Gesture

    private func addPan() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(pan)
    }

    @objc private func handlePan(_ g: UIPanGestureRecognizer) {
        switch g.state {
        case .began:
            isDragging    = true
            dragStartX    = g.location(in: self).x
            baseProgress  = presenter?.progress ?? 0
        case .changed:
            let dx = g.translation(in: self).x
            presenter?.dragChanged(rawDelta: dx, range: 300, baseProgress: baseProgress)
        case .ended, .cancelled, .failed:
            isDragging = false
        default: break
        }
    }

    // MARK: - Update from presenter

    func update(progress: CGFloat, loaded: Int, total: Int) {
        // Show/hide arrow hint
        let showArrow = progress < 0.12
        UIView.animate(withDuration: 0.2) { self.arrowLabel.alpha = showArrow ? 1 : 0 }

        // Update piece layers to match loaded count
        while pieceLayers.count < loaded {
            addPiece(at: pieceLayers.count, total: total)
        }
    }

    private func addPiece(at index: Int, total: Int) {
        let total = presenter?.totalPieces ?? 8
        let h: CGFloat = 32
        let ps: CGFloat = 32
        let ph = (index % 3 == 1) ? ps * 0.82 : ps
        let rodY = bounds.midY - 3.5
        let slotW = rodWidth / CGFloat(total + 1)
        let cx = bounds.midX - rodWidth/2 + CGFloat(index + 0) * slotW + 8

        let piece        = CALayer()
        piece.frame      = CGRect(x: cx, y: rodY - ph/2, width: ps, height: ph)
        piece.cornerRadius = 6

        let g            = CAGradientLayer()
        g.frame          = piece.bounds
        g.cornerRadius   = 6
        let vegTypes     = ["onion", "pepper", "tomato"]
        let type: String = (index % 3 == 1) ? vegTypes[(index / 3) % 3] : "meat"
        switch type {
        case "meat":
            g.colors = [UIColor(hex: "A23C1E").cgColor,
                        UIColor(hex: "7E2A14").cgColor,
                        UIColor(hex: "531608").cgColor]
            g.startPoint = CGPoint(x: 0.3, y: 0); g.endPoint = CGPoint(x: 0.7, y: 1)
        case "onion":
            g.colors = [UIColor.white.cgColor, UIColor(hex: "f3e9d8").cgColor, UIColor(hex: "d9c39a").cgColor]
            g.startPoint = .zero; g.endPoint = CGPoint(x: 0.5, y: 1)
        case "tomato":
            g.colors = [UIColor(hex: "ff7a5c").cgColor, UIColor(hex: "d62f1e").cgColor]
            g.startPoint = CGPoint(x: 0.4, y: 0.35); g.endPoint = CGPoint(x: 1, y: 1)
        case "pepper":
            g.colors = [UIColor(hex: "36b34a").cgColor, UIColor(hex: "1d7a2e").cgColor]
            g.startPoint = .zero; g.endPoint = CGPoint(x: 0.5, y: 1)
        default: break
        }
        piece.addSublayer(g)
        layer.addSublayer(piece)
        pieceLayers.append(piece)

        // Pop animation
        let pop       = CAKeyframeAnimation(keyPath: "transform.scale")
        pop.values    = [0, 1.18, 1.0]
        pop.keyTimes  = [0, 0.60, 1.0]
        pop.duration  = 0.42
        let tf        = CAMediaTimingFunction(controlPoints: 0.34, 1.56, 0.64, 1)
        pop.timingFunction = tf
        piece.add(pop, forKey: "pop")
    }

    func showDoneState() {
        // Cook meat pieces
        pieceLayers.forEach { piece in
            guard let g = piece.sublayers?.first as? CAGradientLayer else { return }
            let anim = CABasicAnimation(keyPath: "colors")
            anim.toValue  = [UIColor(hex: "7a3a1c").cgColor,
                             UIColor(hex: "4a2210").cgColor,
                             UIColor(hex: "2c1206").cgColor]
            anim.duration = 0.6
            anim.fillMode = .forwards
            anim.isRemovedOnCompletion = false
            g.add(anim, forKey: "cook")
        }
        // Pulse ring red
        ringLayer.strokeColor = DS.Colors.ember.cgColor
    }
}
