import UIKit

// MARK: - Coordinator

protocol Coordinator: AnyObject { func start() }

final class AppCoordinator: Coordinator {
    private let window: UIWindow
    private let nav    = UINavigationController()
    private var inputs = BBQInputs()

    init(window: UIWindow) {
        self.window = window
        nav.setNavigationBarHidden(true, animated: false)
        nav.view.backgroundColor = DS.Colors.bg1
    }

    func start() {
        window.rootViewController = nav
        pushHero()
    }

    // MARK: Screens

    private func pushHero() {
        let p  = HeroPresenter()
        let vc = HeroViewController(presenter: p)
        p.view     = vc
        p.onStart  = { [weak self] in self?.pushQuestions() }
        nav.setViewControllers([vc], animated: false)
    }

    private func pushQuestions() {
        let p  = QuestionFlowPresenter(inputs: inputs)
        let vc = QuestionFlowViewController(presenter: p)
        p.view      = vc
        p.onComplete = { [weak self] completed in
            self?.inputs = completed
            self?.pushSignature()
        }
        nav.pushViewController(vc, animated: true)
    }

    private func pushSignature() {
        let p  = SignaturePresenter(inputs: inputs)
        let vc = SignatureViewController(presenter: p)
        p.view   = vc
        p.onDone = { [weak self] in self?.pushResults() }
        nav.pushViewController(vc, animated: true)
    }

    private func pushResults() {
        let result = BBQCalculator.calculate(inputs)
        let p  = ResultsPresenter(inputs: inputs, result: result)
        let vc = ResultsViewController(presenter: p)
        p.view      = vc
        p.onRestart = { [weak self] in
            self?.inputs = BBQInputs()
            self?.nav.popToRootViewController(animated: false)
            self?.pushHero()
        }
        nav.pushViewController(vc, animated: true)
    }
}
