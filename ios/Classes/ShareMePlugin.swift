import Flutter

public class ShareMePlugin: NSObject, FlutterPlugin {
    var viewController: UIViewController?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "share_me", binaryMessenger: registrar.messenger())
        let instance = ShareMePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "share_me" {
            if let args = call.arguments as? [String: Any],
                let title = args["title"] as? String,
                let url = args["url"] as? String {
                let description = args["description"] as? String
                let file = args["file"] as? String
                let subject = args["subject"] as? String
                self.shareMe(title: title, url: url, description: description, file: file, subject: subject)
                result(true)
            } else {
                result(false)
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    public func shareMe(title: String, url: String, description: String?, file: String?, subject: String?) {
        let viewController = UIApplication.shared.delegate?.window??.rootViewController
        var activityItems: [Any] = [title]
        if let description = description {
            activityItems.append(description)
        }
        if let url = URL(string: url) {
            activityItems.append(url)
        }
        if let file = file {
            activityItems.append(URL(fileURLWithPath: file))
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
        activityViewController.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            if completed && activityType == UIActivity.ActivityType.copyToPasteboard {
                UIPasteboard.general.string = description // Copiar solo el contenido de description al seleccionar copiar
            } else if completed && (activityType?.rawValue == "com.apple.mobilenotes.SharingExtension" || activityType?.rawValue == "com.apple.reminders.RemindersEditorExtension") {
                if let description = description {
                    UIPasteboard.general.string = description // Establecer el valor de "description" en el campo "description" de Notes o Reminders
                }
            }
        }
        viewController?.present(activityViewController, animated: true, completion: nil)
    }
}