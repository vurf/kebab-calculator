import SwiftUI
import MessageUI

/// View with buttons for sharing calculation results via different services.
struct ShareView: View {
    @ObservedObject var viewModel: ShareViewModel

    @State private var showAlert = false
    @State private var showSMS = false

    var body: some View {
        VStack(spacing: 12) {
            Button("Поделиться в WhatsApp") {
                if !viewModel.shareWhatsApp() { showAlert = true }
            }
            .buttonStyle(ShareButtonStyle())

            Button("Поделиться в Telegram") {
                if !viewModel.shareTelegram() { showAlert = true }
            }
            .buttonStyle(ShareButtonStyle())

            Button("Отправить SMS") {
                if viewModel.canSendSMS { showSMS = true } else { showAlert = true }
            }
            .buttonStyle(ShareButtonStyle())
        }
        .alert("Приложение не установлено", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
        .sheet(isPresented: $showSMS) {
            MessageComposeView(viewModel: viewModel) {
                showSMS = false
            }
        }
    }
}

/// Wrapper for MFMessageComposeViewController.
struct MessageComposeView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: ShareViewModel
    var onFinish: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onFinish: onFinish)
    }

    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        viewModel.smsController(delegate: context.coordinator) ?? MFMessageComposeViewController()
    }

    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) { }

    final class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        let onFinish: () -> Void
        init(onFinish: @escaping () -> Void) { self.onFinish = onFinish }

        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true)
            onFinish()
        }
    }
}

#Preview {
    ShareView(viewModel: ShareViewModel())
}
