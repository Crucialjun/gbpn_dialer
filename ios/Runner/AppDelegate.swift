import Flutter
import UIKit
import Firebase
import FirebaseCore
import FirebaseMessaging
import PushKit
import flutter_callkit_incoming


@main
@objc class AppDelegate: FlutterAppDelegate,PKPushRegistryDelegate {
  


  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    // Register for VoIP push
        let mainQueue = DispatchQueue.main
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
      voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [.voIP]

        
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Handle updated push credentials
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        print(credentials.token)
        let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
        print(deviceToken)
        //Save deviceToken to your server
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP(deviceToken)
    }

    @objc(pushRegistry:didInvalidatePushTokenForType:) func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("didInvalidatePushTokenFor")
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP("")
    }

     // Handle incoming pushes
    @objc(pushRegistry:didReceiveIncomingPushWithPayload:forType:withCompletionHandler:) func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
         let uuid = UUID().uuidString
        let caller = "Twilio User"

        flutterChannel?.invokeMethod("incoming", arguments: [
            "uuid": uuid,
            "callerName": caller
        ])
        }
    }

}
