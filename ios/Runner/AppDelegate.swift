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
        print("payload \(payload.dictionaryPayload)")
        guard type == .voIP else {
            print("Received non-VoIP push")
            return
        }

        // Extract payload data
        let id = payload.dictionaryPayload["twi_message_id"] as? String ?? ""
        let nameCaller = payload.dictionaryPayload["twi_from"] as? String ?? "Unknown Caller"
        let handle = payload.dictionaryPayload["twi_to"] as? String ?? ""
        let isVideo = payload.dictionaryPayload["isVideo"] as? Bool ?? false
        let callSid = payload.dictionaryPayload["twi_call_sid"] as? String ?? ""
        let accountSid = payload.dictionaryPayload["twi_account_sid"] as? String ?? ""

        // Log extracted data for debugging
        print("Call ID: \(id)")
        print("Caller: \(nameCaller)")
        print("Handle: \(handle)")
        print("Is Video Call: \(isVideo)")
        print("Call SID: \(callSid)")
        print("Account SID: \(accountSid)")

        // Prepare data for CallKit
        let data = flutter_callkit_incoming.Data(id: id, nameCaller: nameCaller, handle: handle, type: isVideo ? 1 : 0)
        data.extra = [
            "callSid": callSid,
            "accountSid": accountSid,
            "platform": "ios"
        ]

        // Show incoming call
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.showCallkitIncoming(data, fromPushKit: true)

        // Ensure completion is called
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion()
        }
    }

}
