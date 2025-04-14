import Flutter
import UIKit
import Firebase
import FirebaseCore
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    // Register for VoIP push
        let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [.voIP]

        
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        TwilioVoiceSDK.registerAccessToken(
            "YOUR_TWILIO_TOKEN", // Replace this with token from your server
            deviceToken: pushCredentials.token,
            completion: { error in
                print("VoIP token registered: \(error?.localizedDescription ?? "Success")")
            }
        )
    }

    func pushRegistry(_ registry: PKPushRegistry,
                      didReceiveIncomingPushWith payload: PKPushPayload,
                      for type: PKPushType,
                      completion: @escaping () -> Void) {

        let uuid = UUID().uuidString
        let callerName = "Twilio User"

        if let controller = window?.rootViewController as? FlutterViewController {
            let channel = FlutterMethodChannel(name: "com.example.callkit", binaryMessenger: controller.binaryMessenger)
            channel.invokeMethod("incoming", arguments: [
                "uuid": uuid,
                "callerName": callerName
            ])
        }

        completion()
    }

}