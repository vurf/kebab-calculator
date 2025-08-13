import Foundation
import MessageUI

/// View model holding shareable result text and coordinating ShareService.
final class ShareViewModel: ObservableObject {
    /// Text representation of calculation results.
    @Published var resultText: String

    private let service: ShareService

    init(resultText: String = """
    Общий вес: 4.2 кг
    Свинина: 2.1 кг
    Курица: 2.1 кг
    Порция на человека: 0.35 кг
    """, service: ShareService = ShareService()) {
        self.resultText = resultText
        self.service = service
    }

    /// Attempts to share text via WhatsApp. Returns `true` if successful.
    func shareWhatsApp() -> Bool {
        service.shareViaWhatsApp(resultText)
    }

    /// Attempts to share text via Telegram. Returns `true` if successful.
    func shareTelegram() -> Bool {
        service.shareViaTelegram(resultText)
    }

    /// Check whether device can send SMS.
    var canSendSMS: Bool { MFMessageComposeViewController.canSendText() }

    /// Provides configured message compose controller if SMS available.
    func smsController(delegate: MFMessageComposeViewControllerDelegate) -> MFMessageComposeViewController? {
        service.smsController(resultText, delegate: delegate)
    }
}
