import SwiftUI
import MessageUI

/// Service responsible for sharing text via external applications.
final class ShareService {
    /// Share text through WhatsApp using URL scheme.
    /// - Returns: `true` if the app is installed and the URL is opened.
    func shareViaWhatsApp(_ text: String) -> Bool {
        guard let url = URL(string: "whatsapp://send?text=\(text.urlEncoded)") else { return false }
        guard UIApplication.shared.canOpenURL(url) else { return false }
        UIApplication.shared.open(url)
        return true
    }

    /// Share text through Telegram using URL scheme.
    /// - Returns: `true` if the app is installed and the URL is opened.
    func shareViaTelegram(_ text: String) -> Bool {
        guard let url = URL(string: "tg://msg?text=\(text.urlEncoded)") else { return false }
        guard UIApplication.shared.canOpenURL(url) else { return false }
        UIApplication.shared.open(url)
        return true
    }

    /// Create SMS compose controller with provided text.
    func smsController(_ text: String, delegate: MFMessageComposeViewControllerDelegate) -> MFMessageComposeViewController? {
        guard MFMessageComposeViewController.canSendText() else { return nil }
        let controller = MFMessageComposeViewController()
        controller.body = text
        controller.messageComposeDelegate = delegate
        return controller
    }
}

private extension String {
    /// Percent escapes string for use in URL query.
    var urlEncoded: String {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}
