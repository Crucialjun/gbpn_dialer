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
        print("didReceiveIncomingPushWith")
        guard type == .voIP else { return }

        // Extract Twilio Voice data from the payload
        if let dictionaryPayload = payload.dictionaryPayload as? [String: AnyObject],
           let twilioData = dictionaryPayload["twi_message_type"] as? String, twilioData == "twilio.voice" {

            // Handle the Twilio Voice push notification
            if let callInvite = dictionaryPayload["twi_call_sid"] as? String {
                print("Incoming call with SID: \(callInvite)")
                // Notify the app or show a call UI
                // Example: Post a notification or update the UI
                
                // Announce the call using SwiftFlutterCallkitIncomingPlugin
                let callData: [String: Any] = [
                    "id": callInvite, // Unique call ID
                    "nameCaller": "Unknown Caller", // Replace with caller's name if available
                    "handle": "Twilio Call", // Replace with caller's number or identifier
                    "type": 0, // 0 for audio call, 1 for video call
                    "extra": ["info": "additional data"], // Optional extra data
                    "ios": ["iconName": "AppIcon"] // Optional iOS-specific data
                ]
                SwiftFlutterCallkitIncomingPlugin.sharedInstance?.showCallkitIncoming(callData)
            }
        }

        completion()
    }

}
