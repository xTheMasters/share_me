import Flutter
import MessageUI
import UIKit

public class ShareMePlugin: NSObject, FlutterPlugin {
    var viewController: UIViewController?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "share_me", binaryMessenger: registrar.messenger())
        let instance = ShareMePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "share_me_system" {
            if let args = call.arguments as? [String: Any],
               let title = args["title"] as? String,
               let url = args["url"] as? String
            {
                let description = args["description"] as? String
                let subject = args["subject"] as? String
                shareMeSystem(title: title, url: url, description: description, subject: subject)
                result(true)
            } else {
                result(false)
            }
        } else if call.method == "share_me_file" {
            if let args = call.arguments as? [String: Any],
               let name = args["name"] as? String,
               let mimeType = args["mimeType"] as? String,
               let file = args["file"] as? FlutterStandardTypedData
            {
                shareMeFile(name: name, mimeType: mimeType, file: file)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    public func shareMeSystem(title: String, url: String, description: String?, subject: String?) {
        let viewController = UIApplication.shared.delegate?.window??.rootViewController
        var activityItems: [Any] = []
        if let title = title as NSString? {
            activityItems.append(title)
        }
        if let url = URL(string: url) {
            activityItems.append(url)
        }
        if let description = description as NSString? {
            activityItems.append(description)
        }
        if let subject = subject, UIApplication.shared.canOpenURL(URL(string: "mailto:")!) {
            activityItems.append(subject)
        }
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        if let popoverPresentationController = activityViewController.popoverPresentationController {
            popoverPresentationController.sourceView = viewController?.view
            popoverPresentationController.sourceRect = CGRect(x: (viewController?.view.bounds.midX)!, y: (viewController?.view.bounds.midY)!, width: 0, height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }
        activityViewController.completionWithItemsHandler = { activityType, completed, _, _ in
            if completed && activityType == UIActivity.ActivityType.copyToPasteboard {
                UIPasteboard.general.string = description
            } else if completed && (activityType?.rawValue == "com.apple.mobilenotes.SharingExtension" || activityType?.rawValue == "com.apple.reminders.RemindersEditorExtension") {
                if let description = description {
                    UIPasteboard.general.string = description
                }
            } else if completed && activityType == UIActivity.ActivityType.mail {
                if !MFMailComposeViewController.canSendMail() {
                    let alertMsg = UIAlertController(title: "Test", message: "Mail services not available.", preferredStyle: UIAlertController.Style.alert)
                    alertMsg.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    viewController?.present(alertMsg, animated: true, completion: nil)
                } else {
                    let emailController = MFMailComposeViewController()
                    emailController.setToRecipients(["mail@egmail.com"])
                    emailController.setSubject(subject ?? "")
                    emailController.mailComposeDelegate = viewController as? MFMailComposeViewControllerDelegate
                    emailController.setMessageBody(description ?? "", isHTML: false)
                    emailController.setValue(subject, forKey: "subject")
                    viewController?.present(emailController, animated: true, completion: nil)
                }
            }
        }
        viewController?.present(activityViewController, animated: true, completion: nil)
    }

    public func shareMeFile(name: String, mimeType _: String, file: FlutterStandardTypedData) {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let tempImagePath = (documentDirectory as NSString).appendingPathComponent("\(name)")
        FileManager.default.createFile(atPath: tempImagePath, contents: file.data, attributes: nil)

        let activityViewController = UIActivityViewController(activityItems: [URL(fileURLWithPath: tempImagePath)], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { _, _, _, _ in
            do {
                try FileManager.default.removeItem(atPath: tempImagePath)
            } catch {
                print("Error al eliminar la imagen temporal: \(error.localizedDescription)")
            }
        }

        if let viewController = UIApplication.shared.keyWindow?.rootViewController {
            viewController.present(activityViewController, animated: true, completion: nil)

            if UIDevice.current.userInterfaceIdiom == .pad {
                if let popoverPresentationController = activityViewController.popoverPresentationController {
                    popoverPresentationController.sourceView = viewController.view
                    popoverPresentationController.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
                    popoverPresentationController.permittedArrowDirections = []
                }
            }
        }
    }
}
