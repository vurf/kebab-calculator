import UIKit

/// Animated BBQ mangal using CALayer for 60fps performance.
/// Reused on Hero, QuestionFlow (mini), Signature, and Results screens.
final class GrillView: UIView {

    // MARK: - Configuration
    struct Config {
        var skewers:   Int            = 0
        var meatSize:  AppetiteOption = .normal
        var lit:       Bool           = false
        var fire:      Bool           = false
        var smoke:     CGFloat        = 0      // 0…1
        var coalCount: Int            = 22
        var cooked:    Bool           = false
    }

    private var cfg = Config()

    // MARK: - Layers
    private var coalLayers:  [CALayer] = []
    private var flameLayers: [CALayer] = []
    private var smokeLayers: [CALayer] = []
    private var skewerLayers:[CALayer] = []

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Public API

    func configure(_ c: Config) {
        cfg = c
        setNeedsLayout()
    }

    /// Call after viewDidAppear to kick off looping animations.
    func startAnimating() {
        animateCoals()
        if cfg.fire  { animateFlames() }
        if cfg.smoke > 0 { animateSmoke() }
    }

    // MARK: - Layout → build scene

    override func layoutSubviews() {
        super.layoutSubviews()
        rebuild()
    }

    private func rebuild() {
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        coalLayers  = []
        flameLayers = []
        smokeLayers = []
        skewerLayers = []

        let w = bounds.width
        let h = bounds.height
        guard w > 0, h > 0 else { return }

        buildMangal(w: w, h: h)
        if cfg.fire  { buildFlames(w: w, h: h) }
        if cfg.smoke > 0 { buildSmoke(w: w, h: h) }
        if cfg.skewers > 0 { buildSkewers(w: w, h: h) }
    }

    // MARK: - Mangal body + coals

    private func buildMangal(w: CGFloat, h: CGFloat) {
        let bodyLeft   = w * 0.04
        let bodyW      = w * 0.92
        let bodyTop    = h * 0.36
        let bodyH      = h * 0.64

        // Body gradient
        let bodyLayer  = CALayer()
        bodyLayer.frame = CGRect(x: bodyLeft, y: bodyTop, width: bodyW, height: bodyH)
        bodyLayer.cornerRadius = 10

        let bodyGrad           = CAGradientLayer()
        bodyGrad.frame         = bodyLayer.bounds
        bodyGrad.cornerRadius  = 10
        bodyGrad.colors        = [DS.Colors.metalA.cgColor, DS.Colors.metalB.cgColor]
        bodyLayer.addSublayer(bodyGrad)
        layer.addSublayer(bodyLayer)

        // Shadow under body
        bodyLayer.shadowColor   = UIColor.black.cgColor
        bodyLayer.shadowOpacity = 0.5
        bodyLayer.shadowRadius  = 15
        bodyLayer.shadowOffset  = CGSize(width: 0, height: 18)

        // Legs
        addLeg(x: bodyLeft + bodyW * 0.16 - 4, y: bodyTop + bodyH, w: 8, h: 26, deg: 8)
        addLeg(x: bodyLeft + bodyW * 0.84 - 4, y: bodyTop + bodyH, w: 8, h: 26, deg: -8)

        // Opening ellipse
        let openLayer  = CALayer()
        let openTop    = bodyTop - h * 0.03
        openLayer.frame = CGRect(x: 0, y: openTop, width: w, height: h * 0.22)
        let openGrad           = CAGradientLayer()
        openGrad.frame         = openLayer.bounds
        openGrad.colors        = [UIColor(hex: "0a0706").cgColor, UIColor(hex: "1a1310").cgColor]
        openLayer.addSublayer(openGrad)
        let openMask           = CAShapeLayer()
        openMask.path          = UIBezierPath(ovalIn: CGRect(x: w*0.02, y: 0, width: w*0.96, height: h*0.24)).cgPath
        openLayer.mask         = openMask
        layer.addSublayer(openLayer)

        // Coal bed
        let coalX = w * 0.10
        let coalW = w * 0.80
        let coalY = bodyTop + bodyH * 0.10
        let cw: CGFloat = 13, ch: CGFloat = 11, gap: CGFloat = 3
        let cols = 11
        let startX = coalX + (coalW - CGFloat(cols) * (cw + gap)) / 2

        for i in 0..<cfg.coalCount {
            let col = i % cols
            let row = i / cols
            let cx  = startX + CGFloat(col) * (cw + gap)
            let cy  = coalY  + CGFloat(row) * (ch + gap)
            let coal = CALayer()
            coal.frame        = CGRect(x: cx, y: cy, width: cw, height: ch)
            coal.cornerRadius = 4
            let isHot = cfg.lit && (i % 3 != 0)
            if isHot {
                let g       = CAGradientLayer()
                g.type      = .radial
                g.frame     = coal.bounds
                g.cornerRadius = 4
                g.colors    = [DS.Colors.emberHot.cgColor,
                               DS.Colors.ember.cgColor,
                               UIColor(hex: "7a1c06").cgColor,
                               UIColor(hex: "2a0d04").cgColor]
                g.locations = [0, 0.35, 0.75, 1.0]
                g.startPoint = CGPoint(x: 0.5, y: 0.45)
                g.endPoint   = CGPoint(x: 1.0, y: 1.0)
                coal.addSublayer(g)
                coal.shadowColor   = DS.Colors.ember.cgColor
                coal.shadowOpacity = 0.70
                coal.shadowRadius  = 5
                coal.shadowOffset  = .zero
            } else {
                coal.backgroundColor = UIColor(hex: "120c0a").cgColor
            }
            layer.addSublayer(coal)
            coalLayers.append(coal)
        }

        // Ember glow above coals
        if cfg.lit {
            let gw = coalW * 0.78, gh = coalW * 0.28
            let glow = CAGradientLayer()
            glow.type   = .radial
            glow.frame  = CGRect(x: w/2 - gw/2, y: coalY - gh*0.1, width: gw, height: gh*1.6)
            glow.colors = [UIColor(hex: "FF781E").withAlphaComponent(0.55).cgColor,
                           UIColor(hex: "FF500A").withAlphaComponent(0.12).cgColor,
                           UIColor.clear.cgColor]
            glow.locations  = [0, 0.45, 0.70]
            glow.startPoint = CGPoint(x: 0.5, y: 0.70)
            glow.endPoint   = CGPoint(x: 1.0, y: 1.0)
            layer.addSublayer(glow)
        }
    }

    private func addLeg(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, deg: CGFloat) {
        let leg = CALayer()
        leg.frame = CGRect(x: x, y: y, width: w, height: h)
        leg.cornerRadius = 4
        let g = CAGradientLayer()
        g.frame = leg.bounds
        g.cornerRadius = 4
        g.colors = [DS.Colors.metalA.cgColor, DS.Colors.metalB.cgColor]
        leg.addSublayer(g)
        leg.transform = CATransform3DMakeRotation(deg * .pi / 180, 0, 0, 1)
        layer.addSublayer(leg)
    }

    // MARK: - Flames

    private func buildFlames(w: CGFloat, h: CGFloat) {
        let topY = bounds.height * 0.33
        for i in 0..<6 {
            let fx: CGFloat = w * 0.15 + CGFloat(i) * w * 0.70 / 5
            let fh: CGFloat = CGFloat(48 + (i % 3) * 16)
            let fl = makeFlame(x: fx - 13, y: topY - fh, w: 26, h: fh)
            layer.addSublayer(fl)
            flameLayers.append(fl)
        }
    }

    private func makeFlame(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) -> CALayer {
        let fl = CALayer()
        fl.frame = CGRect(x: x, y: y, width: w, height: h)
        let g = CAGradientLayer()
        g.frame = fl.bounds
        g.colors = [UIColor(hex: "fff3c4").cgColor,
                    DS.Colors.emberHot.cgColor,
                    DS.Colors.emberDeep.cgColor,
                    UIColor.clear.cgColor]
        g.locations = [0, 0.30, 0.75, 1.0]
        g.startPoint = CGPoint(x: 0.5, y: 0)
        g.endPoint   = CGPoint(x: 0.5, y: 1)
        fl.addSublayer(g)
        // Flame shape mask
        let mask = CAShapeLayer()
        let p    = UIBezierPath()
        p.move(to: CGPoint(x: w/2, y: 0))
        p.addCurve(to: CGPoint(x: w, y: h),
                   controlPoint1: CGPoint(x: w,   y: h*0.25),
                   controlPoint2: CGPoint(x: w*0.9, y: h*0.7))
        p.addCurve(to: CGPoint(x: 0, y: h),
                   controlPoint1: CGPoint(x: w*0.1, y: h*0.7),
                   controlPoint2: CGPoint(x: 0,   y: h*0.25))
        p.close()
        mask.path = p.cgPath
        fl.mask   = mask
        fl.opacity = 0.92
        return fl
    }

    // MARK: - Smoke

    private func buildSmoke(w: CGFloat, h: CGFloat) {
        let smokeY = h * 0.30
        for i in 0..<8 {
            let t: CGFloat = CGFloat(i) / 7
            let sx = w * (0.12 + t * 0.72) + CGFloat.random(in: -6...6)
            let s  = CALayer()
            let sz: CGFloat = 40
            s.frame         = CGRect(x: sx - sz/2, y: smokeY - sz/2, width: sz, height: sz)
            s.cornerRadius  = sz/2
            s.backgroundColor = UIColor(white: 0.84, alpha: 0.30).cgColor
            s.opacity       = 0
            layer.addSublayer(s)
            smokeLayers.append(s)
        }
    }

    // MARK: - Skewers

    private func buildSkewers(w: CGFloat, h: CGFloat) {
        let shown  = min(cfg.skewers, 5)
        let rodW   = w * 1.10
        let topY   = h * 0.10
        let botY   = h * 0.52

        for i in 0..<shown {
            let t: CGFloat = shown <= 1 ? 0.5 : CGFloat(i) / CGFloat(shown - 1)
            let ry = topY + (botY - topY) * (t * 0.78 + 0.06)
            let rod = buildSkewer(width: rodW, midY: ry)
            layer.addSublayer(rod)
            skewerLayers.append(rod)
        }
    }

    private func buildSkewer(width: CGFloat, midY: CGFloat) -> CALayer {
        let h: CGFloat = 5
        let container  = CALayer()
        container.frame = CGRect(x: bounds.width/2 - width/2, y: midY - 15, width: width, height: 30)

        let rod        = CAGradientLayer()
        rod.frame      = CGRect(x: 0, y: 12, width: width, height: h)
        rod.cornerRadius = h/2
        rod.colors     = [UIColor(hex: "e9e3da").cgColor,
                          UIColor(hex: "9a948c").cgColor,
                          UIColor(hex: "6c665f").cgColor]
        rod.locations  = [0, 0.60, 1.0]
        rod.startPoint = CGPoint(x: 0.5, y: 0)
        rod.endPoint   = CGPoint(x: 0.5, y: 1)
        container.addSublayer(rod)

        // Pieces
        let sizes: [AppetiteOption: CGFloat]  = [.light: 11, .normal: 14, .beast: 18]
        let counts: [AppetiteOption: Int]     = [.light: 5,  .normal: 4,  .beast: 3]
        let ps  = sizes[cfg.meatSize]  ?? 14
        let mc  = counts[cfg.meatSize] ?? 4
        let types: [String] = {
            var t: [String] = []
            let veg = ["onion", "pepper", "tomato"]
            for k in 0..<mc {
                t.append("meat")
                if k < mc - 1 { t.append(veg[k % 3]) }
            }
            return t
        }()
        let gap:  CGFloat = ps * 0.18
        let totalW = CGFloat(types.count) * ps + CGFloat(types.count - 1) * gap
        var cx = (width - totalW) / 2

        for type in types {
            let ph  = (type == "onion" || type == "tomato") ? ps * 0.82 : ps
            let py: CGFloat = 12 + h/2 - ph/2
            let piece       = CALayer()
            piece.frame     = CGRect(x: cx, y: py, width: ps, height: ph)
            piece.cornerRadius = 6
            let g           = CAGradientLayer()
            g.frame         = piece.bounds
            g.cornerRadius  = 6
            switch type {
            case "meat":
                if cfg.cooked {
                    g.colors = [UIColor(hex: "7a3a1c").cgColor,
                                UIColor(hex: "4a2210").cgColor,
                                UIColor(hex: "2c1206").cgColor]
                } else {
                    g.colors = [UIColor(hex: "A23C1E").cgColor,
                                UIColor(hex: "7E2A14").cgColor,
                                UIColor(hex: "531608").cgColor]
                }
                g.startPoint = CGPoint(x: 0.3, y: 0)
                g.endPoint   = CGPoint(x: 0.7, y: 1)
            case "onion":
                g.colors = [UIColor.white.cgColor,
                            UIColor(hex: "f3e9d8").cgColor,
                            UIColor(hex: "d9c39a").cgColor]
                g.startPoint = CGPoint(x: 0.5, y: 0)
                g.endPoint   = CGPoint(x: 0.5, y: 1)
            case "tomato":
                g.colors = [UIColor(hex: "ff7a5c").cgColor, UIColor(hex: "d62f1e").cgColor]
                g.startPoint = CGPoint(x: 0.4, y: 0.35); g.endPoint = CGPoint(x: 1, y: 1)
            case "pepper":
                g.colors = [UIColor(hex: "36b34a").cgColor, UIColor(hex: "1d7a2e").cgColor]
                g.startPoint = CGPoint(x: 0.3, y: 0); g.endPoint = CGPoint(x: 0.7, y: 1)
            default: break
            }
            piece.addSublayer(g)
            container.addSublayer(piece)
            cx += ps + gap
        }
        return container
    }

    // MARK: - Animations

    private func animateCoals() {
        for (i, coal) in coalLayers.enumerated() {
            guard cfg.lit && (i % 3 != 0) else { continue }
            let a          = CAKeyframeAnimation(keyPath: "opacity")
            a.values       = [1.0, 1.45, 0.82, 1.0]
            a.keyTimes     = [0, 0.45, 0.70, 1.0]
            a.duration     = 1.8
            a.repeatCount  = .infinity
            a.timeOffset   = Double(i) * 0.13
            coal.add(a, forKey: "flicker")

            let b          = CAKeyframeAnimation(keyPath: "shadowOpacity")
            b.values       = [0.70, 1.0, 0.45, 0.70]
            b.keyTimes     = [0, 0.45, 0.70, 1.0]
            b.duration     = 1.8
            b.repeatCount  = .infinity
            b.timeOffset   = Double(i) * 0.13
            coal.add(b, forKey: "shadowFlicker")
        }
    }

    private func animateFlames() {
        for (i, fl) in flameLayers.enumerated() {
            let sy         = CAKeyframeAnimation(keyPath: "transform.scale.y")
            sy.values      = [1.0, 1.4, 0.85, 1.0]
            sy.keyTimes    = [0, 0.35, 0.60, 1.0]
            sy.duration    = 1.1
            sy.repeatCount = .infinity
            sy.timeOffset  = Double(i) * 0.17
            fl.add(sy, forKey: "flameY")

            let op         = CAKeyframeAnimation(keyPath: "opacity")
            op.values      = [0.92, 1.0, 0.80, 0.92]
            op.keyTimes    = [0, 0.35, 0.60, 1.0]
            op.duration    = 1.1
            op.repeatCount = .infinity
            op.timeOffset  = Double(i) * 0.17
            fl.add(op, forKey: "flameOp")
        }
    }

    private func animateSmoke() {
        let count = smokeLayers.count
        for (i, s) in smokeLayers.enumerated() {
            let dur   = Double.random(in: 4.5...7.5)
            let dy    = CGFloat.random(in: 120...180)
            let dx    = CGFloat.random(in: -22...22)
            let orig  = s.position

            let pos         = CAKeyframeAnimation(keyPath: "position")
            pos.values      = [NSValue(cgPoint: orig),
                               NSValue(cgPoint: CGPoint(x: orig.x + dx*0.5, y: orig.y - dy*0.5)),
                               NSValue(cgPoint: CGPoint(x: orig.x + dx,     y: orig.y - dy))]
            pos.keyTimes    = [0, 0.5, 1.0]

            let sc          = CAKeyframeAnimation(keyPath: "transform.scale")
            sc.values       = [0.4, 1.1, 1.8]
            sc.keyTimes     = [0, 0.5, 1.0]

            let op          = CAKeyframeAnimation(keyPath: "opacity")
            let si          = cfg.smoke
            op.values       = [0.0, si*0.55, si*0.4, 0.0]
            op.keyTimes     = [0, 0.15, 0.60, 1.0]

            let g           = CAAnimationGroup()
            g.animations    = [pos, sc, op]
            g.duration      = dur
            g.repeatCount   = .infinity
            g.timeOffset    = dur * Double(i) / Double(count)
            s.add(g, forKey: "smoke")
        }
    }
}
