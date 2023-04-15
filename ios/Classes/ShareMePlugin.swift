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
               let title = args["title"] as? String,
               let fileData = args["file"] as? FlutterStandardTypedData,
               let file = UIImage(data: fileData.data)
            {
                shareMeFile(title: title, file: file)
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
                UIPasteboard.general.string = description // Copiar solo el contenido de description al seleccionar copiar
            } else if completed && (activityType?.rawValue == "com.apple.mobilenotes.SharingExtension" || activityType?.rawValue == "com.apple.reminders.RemindersEditorExtension") {
                if let description = description {
                    UIPasteboard.general.string = description // Establecer el valor de "description" en el campo "description" de Notes o Reminders
                }
            } else if completed && activityType == UIActivity.ActivityType.mail {
                if !MFMailComposeViewController.canSendMail() {
                    let alertMsg = UIAlertController(title: "Test", message: "Mail services not available.", preferredStyle: UIAlertController.Style.alert)
                    alertMsg.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    viewController?.present(alertMsg, animated: true, completion: nil)
                } else {
                    let emailController = MFMailComposeViewController()
                    emailController.setToRecipients(["mail@egmail.com"]) // Establecer destinatarios
                    emailController.setSubject(subject ?? "") // Establecer el valor de "subject" en el asunto del correo, si está disponible
                    emailController.mailComposeDelegate = viewController as? MFMailComposeViewControllerDelegate // Asignar el delegado para el correo electrónico
                    emailController.setMessageBody(description ?? "", isHTML: false) // Establecer el cuerpo del correo, si está disponible
                    emailController.setValue(subject, forKey: "subject") // Establecer el valor de "subject" en el asunto del correo
                    viewController?.present(emailController, animated: true, completion: nil)
                }
            }
        }
        viewController?.present(activityViewController, animated: true, completion: nil)
    }

    public func shareMeFile(title _: String, file: UIImage) {
        guard let imageData = file.pngData() else {
            print("Error al obtener los datos de la imagen")
            return
        }

        let activityViewController = UIActivityViewController(activityItems: [imageData], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = UIApplication.shared.keyWindow?.rootViewController?.view
        let viewController = UIApplication.shared.keyWindow?.rootViewController
        if let popoverPresentationController = activityViewController.popoverPresentationController {
            popoverPresentationController.sourceView = viewController?.view
            popoverPresentationController.sourceRect = CGRect(x: viewController?.view.bounds.midX ?? 0, y: viewController?.view.bounds.midY ?? 0, width: 0, height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }
        activityViewController.completionWithItemsHandler = { _, _, _, error in
            if let error = error {
                print("Error al compartir: \(error.localizedDescription)")
            } else {
                print("Compartido exitosamente")
            }
        }
        viewController?.present(activityViewController, animated: true, completion: nil)
    }
}

// import Flutter

// public class ShareMePlugin: NSObject, FlutterPlugin {
//     var viewController: UIViewController?

//     public static func register(with registrar: FlutterPluginRegistrar) {
//         let channel = FlutterMethodChannel(name: "share_me", binaryMessenger: registrar.messenger())
//         let instance = ShareMePlugin()
//         registrar.addMethodCallDelegate(instance, channel: channel)
//     }

//     public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//         if call.method == "share_me_system" {
//             if let args = call.arguments as? [String: Any],
//                let title = args["title"] as? String,
//                let url = args["url"] as? String
//             {
//                 let description = args["description"] as? String
//                 let subject = args["subject"] as? String
//                 shareMeSystem(title: title, url: url, description: description, subject: subject)
//                 result(true)
//             } else {
//                 result(false)
//             }
//         } else if call.method == "share_me_file" {
//             if let args = call.arguments as? [String: Any],
//                let title = args["title"] as? String,
//                let fileData = args["file"] as? FlutterStandardTypedData,
//                let file = UIImage(data: fileData.data)
//             {
//                 shareMeFile(title: title, file: file)
//                 result(nil)
//             } else {
//                 result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
//             }
//         } else {
//             result(FlutterMethodNotImplemented)
//         }
//     }

//     public func shareMeSystem(title: String, url: String, description: String?, subject: String?) {
//         let viewController = UIApplication.shared.delegate?.window??.rootViewController
//         var activityItems: [Any] = []
//         if let title = title as NSString? {
//             activityItems.append(title)
//         }
//         if let url = URL(string: url) {
//             activityItems.append(url)
//         }
//         if let description = description as NSString? {
//             activityItems.append(description)
//         }
//         let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
//         if let popoverPresentationController = activityViewController.popoverPresentationController {
//             popoverPresentationController.sourceView = viewController?.view
//             popoverPresentationController.sourceRect = CGRect(x: (viewController?.view.bounds.midX)!, y: (viewController?.view.bounds.midY)!, width: 0, height: 0)
//             popoverPresentationController.permittedArrowDirections = []
//         }
//         activityViewController.completionWithItemsHandler = { [description, subject] activityType, completed, _, _ in
//             if completed && activityType == UIActivity.ActivityType.copyToPasteboard {
//                 UIPasteboard.general.string = description
//             } else if completed && (activityType?.rawValue == "com.apple.mobilenotes.SharingExtension" || activityType?.rawValue == "com.apple.reminders.RemindersEditorExtension") {
//                 if let description = description {
//                     UIPasteboard.general.string = description
//                 }
//             } else if completed && (activityType?.rawValue == "com.apple.UIKit.mailcompose") {
//                 if let subject = subject {
//                     activityViewController.setValue(subject, forKey: "subject")
//                 }
//             } else if completed && (activityType?.rawValue == "com.apple.reminders.RemindersEditorExtension") {
//                 if let description = description {
//                     UIPasteboard.general.string = description
//                 }
//             }
//         }
//         viewController?.present(activityViewController, animated: true, completion: nil)
//     }

//     public func shareMeFile(title: String, file: UIImage) {
//         guard let imageData = file.pngData() else {
//             print("Error al obtener los datos de la imagen")
//             return
//         }

//         let activityViewController = UIActivityViewController(activityItems: [title, imageData], applicationActivities: nil)
//         activityViewController.popoverPresentationController?.sourceView = UIApplication.shared.keyWindow?.rootViewController?.view
//         let viewController = UIApplication.shared.keyWindow?.rootViewController
//         if let popoverPresentationController = activityViewController.popoverPresentationController {
//             popoverPresentationController.sourceView = viewController?.view
//             popoverPresentationController.sourceRect = CGRect(x: viewController?.view.bounds.midX ?? 0, y: viewController?.view.bounds.midY ?? 0, width: 0, height: 0)
//             popoverPresentationController.permittedArrowDirections = []
//         }
//         activityViewController.completionWithItemsHandler = { _, _, _, error in
//             if let error = error {
//                 print("Error al compartir: \(error.localizedDescription)")
//             } else {
//                 print("Compartido exitosamente")
//             }
//         }
//         viewController?.present(activityViewController, animated: true, completion: nil)
//     }
// }
