import Flutter

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
                let url = args["url"] as? String {
                let description = args["description"] as? String
                let subject = args["subject"] as? String
                self.shareMeSystem(title: title, url: url, description: description, subject: subject)
                result(true)
            } else {
                result(false)
            }
        } else if call.method == "share_me_file" {
            if let args = call.arguments as? [String: Any],
                let title = args["title"] as? String,
                   let fileData = args["file"] as? FlutterStandardTypedData,
                   let file = UIImage(data: fileData.data) {
                    self.shareMeFile(title: title, file: file)
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
    if let description = description {
        // Agregar el título a la descripción si existe
        let fullDescription = title + "\n" + description
        activityItems.append(fullDescription)
    }
    if let url = URL(string: url) {
        activityItems.append(url)
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


    public func shareMeFile(title: String, file: UIImage) {
    let activityViewController = UIActivityViewController(activityItems: [title, file], applicationActivities: nil)
    activityViewController.popoverPresentationController?.sourceView = UIApplication.shared.keyWindow?.rootViewController?.view
    let viewController = UIApplication.shared.keyWindow?.rootViewController
    if let popoverPresentationController = activityViewController.popoverPresentationController {
        popoverPresentationController.sourceView = viewController?.view
        popoverPresentationController.sourceRect = CGRect(x: viewController?.view.bounds.midX ?? 0, y: viewController?.view.bounds.midY ?? 0, width: 0, height: 0)
        popoverPresentationController.permittedArrowDirections = []
    }
    activityViewController.completionWithItemsHandler = { _, _, _, _ in
        // Verificar si la actividad fue para guardar en la galería
        if UIActivity.ActivityType.saveToCameraRoll != nil {
            // Guardar la imagen en la galería
            UIImageWriteToSavedPhotosAlbum(file, nil, nil, nil)
        }
    }
    viewController?.present(activityViewController, animated: true, completion: nil)
}

}