import UIKit

// ═══════════════════════════════════════════════
// MARK: - Hero
// ═══════════════════════════════════════════════

protocol HeroViewProtocol: AnyObject {}

final class HeroPresenter {
    weak var view: HeroViewProtocol?
    var onStart: (() -> Void)?
    func didTapStart() { onStart?() }
}

// ═══════════════════════════════════════════════
// MARK: - Question Flow
// ═══════════════════════════════════════════════

protocol QuestionFlowViewProtocol: AnyObject {
    func showQuestion(_ step: QuestionStep, stepIndex: Int, total: Int)
    func exitCard(direction: CGFloat, completion: @escaping () -> Void)
    func triggerHaptic(_ style: HapticStyle)
}

final class QuestionFlowPresenter {
    weak var view: QuestionFlowViewProtocol?
    var onComplete: ((BBQInputs) -> Void)?

    private(set) var inputs: BBQInputs
    private(set) var stepIndex = 0
    private let steps = QuestionStep.allCases

    init(inputs: BBQInputs) { self.inputs = inputs }

    var currentStep: QuestionStep { steps[stepIndex] }
    var totalSteps:  Int          { steps.count }

    // Setters called by QuestionContentViews
    func setCount(_ v: Int)               { inputs.count    = max(1, min(30, v)) }
    func setKids(_ v: KidsOption)         { inputs.kids     = v }
    func setAlcohol(_ v: AlcoholOption)   { inputs.alcohol  = v }
    func setAppetite(_ v: AppetiteOption) { inputs.appetite = v }
    func setMeats(_ v: [MeatType]) { if !v.isEmpty { inputs.meats = v } }
    var selectedMeats: [MeatType]  { inputs.meats }

    func advance() {
        view?.triggerHaptic(.medium)
        view?.exitCard(direction: 1) { [weak self] in
            guard let self else { return }
            if self.stepIndex < self.steps.count - 1 {
                self.stepIndex += 1
                self.view?.showQuestion(self.currentStep,
                                        stepIndex: self.stepIndex,
                                        total: self.totalSteps)
            } else {
                self.onComplete?(self.inputs)
            }
        }
    }
}

// ═══════════════════════════════════════════════
// MARK: - Signature
// ═══════════════════════════════════════════════

protocol SignatureViewProtocol: AnyObject {
    func updateProgress(_ p: CGFloat, loaded: Int, total: Int)
    func showCompletion()
    func triggerHaptic(_ style: HapticStyle)
}

final class SignaturePresenter {
    weak var view: SignatureViewProtocol?
    var onDone: (() -> Void)?

    let totalPieces: Int
    private(set) var progress: CGFloat = 0
    private var lastLoaded    = 0
    private var isDone        = false

    init(inputs: BBQInputs) {
        totalPieces = max(6, min(12, Int((Double(inputs.count) * 1.2).rounded())))
    }

    var loaded: Int { Int((progress * CGFloat(totalPieces)).rounded()) }

    func dragChanged(rawDelta: CGFloat, range: CGFloat, baseProgress: CGFloat) {
        guard !isDone else { return }
        progress = max(0, min(1, baseProgress + rawDelta / range))
        let l = loaded
        if l > lastLoaded {
            view?.triggerHaptic(.light)
            lastLoaded = l
        }
        view?.updateProgress(progress, loaded: l, total: totalPieces)
        if l >= totalPieces {
            isDone = true
            view?.triggerHaptic(.heavy)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
                self?.view?.triggerHaptic(.success)
            }
            view?.showCompletion()
        }
    }

    func didTapShowResults() { onDone?() }
}

// ═══════════════════════════════════════════════
// MARK: - Results
// ═══════════════════════════════════════════════

protocol ResultsViewProtocol: AnyObject {}

final class ResultsPresenter {
    weak var view: ResultsViewProtocol?
    var onRestart: (() -> Void)?

    let inputs:  BBQInputs
    let result:  BBQResult
    var list:    [ShoppingItem] { BBQCalculator.shoppingList(inputs: inputs, result: result) }

    init(inputs: BBQInputs, result: BBQResult) {
        self.inputs = inputs
        self.result = result
    }

    func didTapRestart() { onRestart?() }
}

// ═══════════════════════════════════════════════
// MARK: - Haptic helper
// ═══════════════════════════════════════════════

enum HapticStyle { case light, medium, heavy, success }

func fireHaptic(_ style: HapticStyle) {
    switch style {
    case .light:
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    case .medium:
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    case .heavy:
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    case .success:
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
